//
//  ContentView.swift
//  AmiiboReader
//
//  Created by Shinichiro Oba on 2022/02/14.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        if let amiiboData = viewModel.amiiboData {
            Text("UID: " + amiiboData.uid.hexString)
            Text("head: " + amiiboData.head.hexString)
            Text("tail: " + amiiboData.tail.hexString)
        }
        
        Button("読み込み") {
            viewModel.resetAmiiboData()
            viewModel.scan()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
