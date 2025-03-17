//
//  DeckOverviewView.swift
//  StudyStacks
//
//  Created by Giselle Eliasi on 3/4/25.
//

import SwiftUI

struct StackDetailView: View {
    @State private var isFavorited = false
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Stack Title")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Example Text........")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 340, height: 200)
                    
                    Text("Card Text")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Button(action: {
                        }) {
                            Image(systemName: "chevron.left")
                        }
                        
                        Spacer()
                        
                        Button(action: {
                        }) {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .padding(.horizontal, 24)
                    .foregroundColor(.gray)
                }
                .padding()
                
                VStack(alignment: .leading) {
                    Text("Terms in this Stack")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.top)
                        .padding(.leading, 16)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(0..<5, id: \.self) { index in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Term")
                                            .font(.headline)
                                            .foregroundColor(Color.prim)
                                        
                                        Text("Example Text.........")
                                            .font(.body)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Button(action: {
                }) {
                    Text("Start Studying")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.prim)
                        .cornerRadius(12)
                }
                .padding()
            }
            // Added tool bar
            .navigationBarHidden(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                    }) {
                        Text("< Back")
                            .foregroundColor(Color.prim)
                            .padding()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive, action: {
                        }) {
                            Label("Delete Deck", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                            .padding()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isFavorited.toggle()
                    }) {
                        Image(systemName: isFavorited ? "star.fill" : "star")
                            .foregroundColor(isFavorited ? Color.yellow : Color.gray)
                            .font(.title2)
                            .padding()
                    }
                }
            }
        }
    }
}

struct StackDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StackDetailView()
    }
}
