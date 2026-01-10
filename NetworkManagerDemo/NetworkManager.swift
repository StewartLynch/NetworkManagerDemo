//
//----------------------------------------------
// Original project: NetworkManagerDemo
//
// Follow me on Mastodon: https://iosdev.space/@StewartLynch
// Follow me on Threads: https://www.threads.net/@stewartlynch
// Follow me on Bluesky: https://bsky.app/profile/stewartlynch.bsky.social
// Follow me on X: https://x.com/StewartLynch
// Follow me on LinkedIn: https://linkedin.com/in/StewartLynch
// Email: slynch@createchsol.com
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.


import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func fetchAndDecodeJSON<T: Decodable>(from url:String, configureDecoder: ((JSONDecoder) -> ())? = nil) async -> T? {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return nil
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Network error: Response was not HTTPURLResponse")
                return nil
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                print("HTTP error: status code \(httpResponse.statusCode)")
                return nil
            }
            do {
                let decoder = JSONDecoder()
                configureDecoder?(decoder)
                return try decoder.decode(T.self, from: data)
            } catch let error as DecodingError {
                print(decodingError(error: error))
                return nil
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                print("Data as string: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to String")")
                return nil
            }
        } catch {
            print("Request error \(error.localizedDescription)")
            return nil
        }
        
    }
    
    func decodingError(error: DecodingError) -> String {
        switch error {
        case .typeMismatch(let type, let context):
            """
            Decoding Error: Type mismatch for type \(type)
            Context: \(context.debugDescription)
            Coding path: \(context.codingPath.map { $0.stringValue}.joined(separator: " -> "))
            """
        case .valueNotFound(let type, let context):
            """
            Decoding Error: Value of type \(type) not found
            Context: \(context.debugDescription)
            Coding path: \(context.codingPath.map { $0.stringValue}.joined(separator: " -> "))
            """
        case .keyNotFound(let codingKey, let context):
            """
            Decoding Error: Key '\(codingKey.stringValue)' not found
            Context: \(context.debugDescription)
            Coding path: \(context.codingPath.map { $0.stringValue}.joined(separator: " -> "))
            """
        case .dataCorrupted(let context):
            """
            Decoding Error: Data corrupted
            Context: \(context.debugDescription)
                Coding path: \(context.codingPath.map { $0.stringValue}.joined(separator: " -> "))
            """
        @unknown default:
            """
            Unknown error: \(error.localizedDescription)
            """
        }
    }
}
