//
//  AmiiboAPI.swift
//  AmiiboReader
//
//  Created by Shinichiro Oba on 2022/02/14.
//

import Foundation

struct Amiibo: Decodable {
    let name: String
    let character: String
    let amiiboSeries: String
    let gameSeries: String
    let type: String
    let image: URL
}

class AmiiboAPI {
    
    struct Response: Decodable {
        let amiibo: [Amiibo]
    }
    
    static func request(head: Data, tail: Data) async throws -> Response {
        let url = URL(string: "https://amiiboapi.com/api/amiibo/?head=\(head.hexString)&tail=\(tail.hexString)")!
        let data = try await URLSession.shared.data(for: URLRequest(url: url)).0
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

extension Data {
    public var hexString: String {
        return map { String(format: "%02x", $0) }.joined(separator: "")
    }
}
