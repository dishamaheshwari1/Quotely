//
//  QuoteListView.swift
//  Quotely
//
//  Created by Disha Maheshwari on 1/6/26.
//

import SwiftUI
import SwiftData

struct QuoteListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Quote.dateCreated, order: .reverse) private var quotes: [Quote]
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    // Match the color array exactly
    let backgroundColors: [Color] = [
        Color(red: 0.925, green: 0.784, blue: 0.604),
        Color(red: 0.6, green: 0.05, blue: 0.1),
        Color(red: 0.8, green: 0.3, blue: 0.0),
        Color(red: 0.95, green: 0.75, blue: 0.1),
        Color(red: 0.0, green: 0.4, blue: 0.25),
        Color(red: 0.05, green: 0.2, blue: 0.5),
        Color(red: 0.35, green: 0.1, blue: 0.55),
        Color(red: 0.35, green: 0.2, blue: 0.05),
        Color(red: 0.25, green: 0.3, blue: 0.35),
        Color.black
    ]
    
    var body: some View {
        ScrollView {
            if quotes.isEmpty {
                ContentUnavailableView("No Quotes Yet", systemImage: "book.closed")
            } else {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(quotes) { quote in
                        // Wrap each tile in a NavigationLink to Edit it
                        NavigationLink(destination: QuoteEditorView(quoteToEdit: quote)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(quote.text)
                                    .fontDesign(.serif)
                                    .font(.headline)
                                    .lineLimit(4)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor((quote.colorIndex == 0 || quote.colorIndex == 3) ? .black : .white)
                                
                                Spacer()
                                
                                Text(quote.dateCreated.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundColor((quote.colorIndex == 0 || quote.colorIndex == 3) ? .black.opacity(0.6) : .white.opacity(0.6))
                            }
                            .frame(height: 150)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(backgroundColors[quote.colorIndex])
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("My Quotes") // <--- Renamed
        .background(Color.black.ignoresSafeArea())
    }
}
