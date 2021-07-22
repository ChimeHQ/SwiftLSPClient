import XCTest
import JSONRPC
import SwiftLSPClient

class JSONRPCLanguageServerTests: XCTestCase {
    func testHoverRequest() throws {
        let dataTransport = MockDataTransport()

        let server = JSONRPCLanguageServer(dataTransport: dataTransport)

        let position = Position(line: 5, character: 5)
        let params = TextDocumentPositionParams(uri: "file://somefile.txt", position: position)

        var result: LanguageServerResult<HoverResponse>? = nil

        let exp = XCTestExpectation(description: "Server Result Expectation")

        server.hover(params: params) { (serverResult) in
            result = serverResult

            exp.fulfill()
        }

        // now write the response
        let hoverResult = Hover(contents: HoverContents.markedString(MarkedString.string("foo")),
                                    range: LSPRange(startPair: (10, 10), endPair: (20, 20)))
        let serverResponse = JSONRPCResponse(id: JSONId(1), result: hoverResult)
        let serverResponseData = try MessageTransport.encode(serverResponse)
        dataTransport.mockRead(serverResponseData)

        wait(for: [exp], timeout: 1.0)

        // verify the request
        let clientRequest = JSONRPCRequest(id: JSONId(1), method: ProtocolMethod.TextDocument.Hover, params: params)
        let clientRequestData = try MessageTransport.encode(clientRequest)

        XCTAssertEqual(dataTransport.writtenData, [clientRequestData])

        // and verify the response
        let hover = try XCTUnwrap(result?.get())

        XCTAssertEqual(hover.contents, HoverContents.markedString(MarkedString.string("foo")))
        XCTAssertEqual(hover.range, LSPRange(startPair: (10, 10), endPair: (20, 20)))
    }
}
