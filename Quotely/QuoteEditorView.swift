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
    @Environment(\.modelContext) private var modelContext
    
    // 2. STATE VARIABLES
    @State private var quoteText: String = ""
    @State private var noteText: String = ""
    @State private var colorIndex: Int = 0
    @State private var showSaveConfirmation: Bool = false
    
    // 3. JEWEL TONES CONFIGURATION
    // Order: Sepia -> Rainbow (R-O-Y-G-B-P) -> Neutrals (Brown-Gray-Black)
    let backgroundColors: [Color] = [
        Color(red: 0.925, green: 0.784, blue: 0.604), // 0. Sepia
        Color(red: 0.6, green: 0.05, blue: 0.1),      // 1. Ruby Red
        Color(red: 0.8, green: 0.3, blue: 0.0),       // 2. Burnt Orange
        Color(red: 0.95, green: 0.75, blue: 0.1),     // 3. Golden Yellow
        Color(red: 0.0, green: 0.4, blue: 0.25),      // 4. Emerald Green
        Color(red: 0.05, green: 0.2, blue: 0.5),      // 5. Sapphire Blue
        Color(red: 0.35, green: 0.1, blue: 0.55),     // 6. Royal Purple
        Color(red: 0.35, green: 0.2, blue: 0.05),     // 7. Rich Brown
        Color(red: 0.25, green: 0.3, blue: 0.35),     // 8. Slate Gray
        Color.black                                   // 9. Black
    ]
    
    // Helper to determine if text should be dark (for light backgrounds)
    var isLightBackground: Bool {
        // Sepia (0) and Golden Yellow (3) need black text
        return colorIndex == 0 || colorIndex == 3
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // LAYER 1: The Background Color
                backgroundColors[colorIndex]
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.5), value: colorIndex)
                    .onTapGesture {
                        hideKeyboard()
                    }
                
                // LAYER 2: The Liquid Glass Editor
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        // The Main Quote Input (Now Dynamic!)
                        TextField("type your quote here", text: $quoteText, axis: .vertical)
                            .fontDesign(.serif)
                            .font(.title2)
                            .multilineTextAlignment(.center) // <--- Centered Text
                            .foregroundColor(isLightBackground ? .black : .white)
                            .tint(isLightBackground ? .black : .white)
                            .padding(.top, 10)
                        
                        // The "Note to Self" Input
                        TextField("note to self...", text: $noteText)
                            .fontDesign(.serif)
                            .font(.body)
                            .italic()
                            .multilineTextAlignment(.center) // <--- Centered Text
                            .foregroundColor(isLightBackground ? .black.opacity(0.8) : .white.opacity(0.8))
                            .tint(isLightBackground ? .black : .white)
                    }
                    .padding(25)
                    .background(.ultraThinMaterial) // Liquid Glass effect
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
                    .padding(.horizontal, 30)
                    // Ensure the box has a minimum size but grows as you type
                    .frame(minHeight: 150)
                    
                    Spacer()
                    
                    // LAYER 3: Buttons (Centered at Bottom)
                    HStack(spacing: 40) { // Spacing between buttons
                        // Save Button
                        Button(action: saveQuote) {
                            HStack {
                                Image(systemName: "arrow.down.doc.fill")
                                Text("Save")
                            }
                            .fontDesign(.serif)
                            .fontWeight(.medium)
                            .foregroundColor(isLightBackground ? .black : .white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 25)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                        }
                        
                        // Grid/Library Button
                        NavigationLink(destination: QuoteListView()) {
                            Image(systemName: "square.grid.2x2")
                                .font(.title2)
                                .foregroundColor(isLightBackground ? .black : .white)
                                .padding(15)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.bottom, 30) // Lift up from bottom edge
                }
                
                // LAYER 4: "Saved" Feedback Overlay
                if showSaveConfirmation {
                    Text("Saved")
                        .fontDesign(.serif)
                        .font(.title3)
                        .foregroundColor(isLightBackground ? .black : .white)
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(100)
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
                                changeColor(direction: 1) // Swipe Left (Next)
                            } else if horizontalAmount > 50 {
                                changeColor(direction: -1) // Swipe Right (Previous)
                            }
                        }
                        // Detect Vertical Swipe Down (Save shortcut)
                        else if verticalAmount > 100 {
                            saveQuote()
                        }
                    }
            )
        }
    }
    
    // LOGIC HELPERS
    
    func changeColor(direction: Int) {
        withAnimation {
            let count = backgroundColors.count
            // Modulo arithmetic for infinite looping
            if direction > 0 {
                // Moving forward: (0 -> 1 -> ... -> 9 -> 0)
                colorIndex = (colorIndex + 1) % count
            } else {
                // Moving backward: (0 -> 9 -> ... -> 1 -> 0)
                // We add 'count' before modulo to handle negative numbers correctly
                colorIndex = (colorIndex - 1 + count) % count
            }
        }
    }
    
    func saveQuote() {
        guard !quoteText.isEmpty else { return }
        
        let newQuote = Quote(text: quoteText, note: noteText, colorIndex: colorIndex)
        modelContext.insert(newQuote)
        
        hideKeyboard()
        
        withAnimation(.spring()) {
            showSaveConfirmation = true
            quoteText = ""
            noteText = ""
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showSaveConfirmation = false
            }
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    QuoteEditorView()
        .modelContainer(for: Quote.self, inMemory: true)
}
