//
//  QuoteEditorView.swift
//  Quotely
//
//  Created by Disha Maheshwari on 1/6/26.
//

import SwiftUI
import SwiftData

struct QuoteEditorView: View {
    // 1. DATABASE CONNECTIVITY
    // This gives us access to the SwiftData storage to save later
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    // 2. STATE VARIABLES
    @State private var quoteText: String = ""
    @State private var noteText: String = ""
    @State private var colorIndex: Int = 0
    @State private var showSaveConfirmation: Bool = false
    
    // 3. JEWEL TONES CONFIGURATION
    // Jewel Red, Jewel Blue, Jewel Green, Burnt Orange, Sepia
    let backgroundColors: [Color] = [
        Color(red: 0.6, green: 0.05, blue: 0.1), // Ruby
        Color(red: 0.05, green: 0.2, blue: 0.5), // Sapphire
        Color(red: 0.0, green: 0.4, blue: 0.25), // Emerald
        Color(red: 0.8, green: 0.3, blue: 0.0), // Burnt Orange
        Color(red: 0.9, green: 0.85, blue: 0.7)  // Sepia
    ]
    
    var body: some View {
        ZStack {
            // LAYER 1: The Background
            // transitions ensure the color fades smoothly instead of snapping
            backgroundColors[colorIndex]
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: colorIndex)
                .onTapGesture {
                    // Tapping background dismisses keyboard
                    hideKeyboard()
                }
            
            // LAYER 2: The Liquid Glass Editor
            VStack(spacing: 15) {
                // The Main Quote Input
                TextEditor(text: $quoteText)
                    .fontDesign(.serif) // The fancy font
                    .font(.title2)
                    .scrollContentBackground(.hidden) // Removes default white background
                    .frame(height: 300)
                    .foregroundColor(colorIndex == 4 ? .black : .white) // Black text for Sepia, White for others
                
                // The "Note to Self" Input
                TextField("note to self...", text: $noteText)
                    .fontDesign(.serif)
                    .font(.body)
                    .italic()
                    .foregroundColor(colorIndex == 4 ? .black.opacity(0.7) : .white.opacity(0.7))
            }
            .padding()
            // This is the "Liquid Glass" Magic
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
            .padding(30) // Margin from screen edges
            
            // LAYER 3: Save Confirmation (Visual feedback)
            if showSaveConfirmation {
                Text("Saved")
                    .fontDesign(.serif)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .transition(.opacity)
                    .onAppear {
                        // Auto-hide after 1 second
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation { showSaveConfirmation = false }
                        }
                    }
            }
        }
        // GESTURES
        .gesture(
            DragGesture()
                .onEnded { value in
                    let horizontalAmount = value.translation.width
                    let verticalAmount = value.translation.height
                    
                    // Detect Horizontal Swipe (Change Color)
                    if abs(horizontalAmount) > abs(verticalAmount) {
                        if horizontalAmount < -50 {
                            // Swiped Left
                            changeColor(direction: 1)
                        } else if horizontalAmount > 50 {
                            // Swiped Right
                            changeColor(direction: -1)
                        }
                    }
                    // Detect Vertical Swipe Down (Save)
                    else if verticalAmount > 100 {
                        saveQuote()
                    }
                }
        )
    }
    
    // LOGIC HELPERS
    
    func changeColor(direction: Int) {
        withAnimation {
            let newIndex = colorIndex + direction
            // Keep index within bounds of the array (0 to 4)
            if newIndex >= 0 && newIndex < backgroundColors.count {
                colorIndex = newIndex
            }
        }
    }
    
    func saveQuote() {
        // Ensure not empty
        guard !quoteText.isEmpty else { return }
        
        let newQuote = Quote(text: quoteText, note: noteText, colorIndex: colorIndex)
        modelContext.insert(newQuote)
        
        // Reset screen logic
        withAnimation {
            showSaveConfirmation = true
            quoteText = ""
            noteText = ""
        }
        
        hideKeyboard()
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Preview to see it in Xcode
#Preview {
    QuoteEditorView()
        .modelContainer(for: Quote.self, inMemory: true)
}
