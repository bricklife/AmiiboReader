//
//  ViewModel.swift
//  AmiiboReader
//
//  Created by Shinichiro Oba on 2022/02/14.
//

import Foundation
import CoreNFC

struct AmiiboData {
    let uid: Data
    let head: Data
    let tail: Data
}

extension Data {
    public var hexString: String {
        return map { String(format: "%02x", $0) }.joined(separator: "")
    }
}

@MainActor class ViewModel: NSObject, ObservableObject {
    
    private var readerSession: NFCTagReaderSession?
    
    @Published var amiiboData: AmiiboData?
    
    func scan() {
        guard NFCTagReaderSession.readingAvailable else {
            print("Not Supported")
            return
        }
        
        self.readerSession = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self, queue: nil)
        readerSession?.alertMessage = "amiiboを近づけてください"
        readerSession?.begin()
    }
    
    func resetAmiiboData() {
        self.amiiboData = nil
    }
    
    func updateAmiiboData(uid: Data, head: Data, tail: Data) {
        self.amiiboData = AmiiboData(uid: uid, head: head, tail: tail)
    }
}

extension ViewModel: NFCTagReaderSessionDelegate {
    
    nonisolated func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print(#function)
    }
    
    nonisolated func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print(#function, error)
    }
    
    nonisolated func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        print(#function, tags)
        
        guard let tag = tags.first, case .miFare(let mifare) = tag else {
            session.alertMessage = "amiiboが見つかりませんでした"
            return
        }
        
        print(mifare, mifare.identifier as NSData)
        
        Task {
            do {
                try await session.connect(to: tag)
                
                // READ(0x30) at Page 21
                let head = try await mifare.sendMiFareCommand(commandPacket: Data([0x30, 21])).prefix(4)
                
                // READ(0x30) at Page 22
                let tail = try await mifare.sendMiFareCommand(commandPacket: Data([0x30, 22])).prefix(4)
                
                await updateAmiiboData(uid: mifare.identifier, head: head, tail: tail)
                
                session.invalidate()
            } catch {
                session.invalidate(errorMessage: error.localizedDescription)
            }
        }
    }
}
