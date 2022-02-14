//
//  ViewModel.swift
//  AmiiboReader
//
//  Created by Shinichiro Oba on 2022/02/14.
//

import Foundation
import CoreNFC

@MainActor class ViewModel: NSObject, ObservableObject {
    
    private var readerSession: NFCTagReaderSession?
    
    @Published var amiibo: Amiibo?
    
    func scan() {
        guard NFCTagReaderSession.readingAvailable else {
            print("Not Supported")
            return
        }
        
        self.readerSession = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self, queue: nil)
        readerSession?.alertMessage = "amiiboを近づけてください"
        readerSession?.begin()
    }
    
    func resetAmiibo() {
        self.amiibo = nil
    }
    
    func updateAmiibo(_ amiibo: Amiibo) {
        self.amiibo = amiibo
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
                
                let apiResponse = try await AmiiboAPI.request(head: head, tail: tail)
                
                if let amiibo = apiResponse.amiibo.first {
                    await updateAmiibo(amiibo)
                }
                
                session.invalidate()
            } catch {
                session.invalidate(errorMessage: error.localizedDescription)
            }
        }
    }
}
