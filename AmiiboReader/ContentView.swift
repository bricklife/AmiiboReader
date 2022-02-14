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
        if let amiibo = viewModel.amiibo {
            Text(amiibo.name)
            AsyncImage(url: amiibo.image) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .scaledToFit()
            .padding()
        }
        
        Button("Scan") {
            viewModel.resetAmiibo()
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
