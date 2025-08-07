//
//  PhotoCollectionView.swift
//  Findation
//
//  Created by 변관영 on 8/7/25.
//

//
//  ContentView.swift
//  Findation
//
//  Created by Nico on 8/3/25.
//

import SwiftUI

struct PhotoCollectionView: View {
    @EnvironmentObject var session: SessionStore

    var body: some View {
        VStack {
            
        }
            .frame(maxWidth: .infinity)
            .frame(width: 353, height: 455)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(20)
        }
    }

#Preview {
    PhotoCollectionView()
}
