//
//  QuoteEditorView.swift
//  Quotely
//
//  Created by Disha Maheshwari on 1/6/26.
//

import SwiftUI
import SwiftData

struct QuoteEditorView: View {
    @Environment(\.modelContext) private var modelContext
    
    // --- INPUTS ---
    // If quote is nil, we are in "New Entry" mode
    let quote: Quote?
    var isNewEntryMode: Bool { quote == nil }
    
    // --- LOCAL STATE (For New Entries) ---
    @State private var tempText: String = ""
    @State private var tempNote: String = ""
    @State private var tempColorIndex: Int = 0
    
    // --- UI STATE ---
    @FocusState private var isFocused: Bool
    @State private var showSaveFeedback: Bool = false
    
    // --- JEWEL TONES ---
    let backgroundColors: [Color] = [
        Color(red: 0.925, green: 0.784, blue: 0.604), // Sepia
        Color(red: 0.6, green: 0.05, blue: 0.1),      // Ruby
        Color(red: 0.8, green: 0.3, blue: 0.0),       // Orange
        Color(red: 0.95, green: 0.75, blue: 0.1),     // Yellow
        Color(red: 0.0, green: 0.4, blue: 0.25),      // Emerald
        Color(red: 0.05, green: 0.2, blue: 0.5),      // Sapphire
        Color(red: 0.35, green: 0.1, blue: 0.55),     // Purple
        Color(red: 0.35, green: 0.2, blue: 0.05),     // Brown
        Color(red: 0.25, green: 0.3, blue: 0.35),     // Slate
        Color.black
    ]
    
    // Determine active color and text contrast
    var activeColorIndex: Int {
        isNewEntryMode ? tempColorIndex : (quote?.colorIndex ?? 0)
    }
    
    var isLightBackground: Bool {
        return activeColorIndex == 0 || activeColorIndex == 3
    }
    
    var textColor: Color { isLightBackground ? .black : .white }
    
    var body: some View {
        ZStack {
            // 1. BACKGROUND
            backgroundColors[activeColorIndex]
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: activeColorIndex)
                .onTapGesture { isFocused = false }
            
            // 2. CENTERED TEXT (Floating, No Box)
            VStack(spacing: 25) {
                Spacer()
                
                // MAIN QUOTE INPUT
                TextField("type your quote here", text: Binding(
                    get: { isNewEntryMode ? tempText : quote!.text },
                    set: { val in if isNewEntryMode { tempText = val } else { quote!.text = val } }
                ), axis: .vertical)
                .fontDesign(.serif)
                .font(.system(size: 34, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundColor(textColor)
                .tint(textColor)
                .focused($isFocused)
                .padding(.horizontal, 24)
                
                // NOTE TO SELF INPUT
                TextField("note to self...", text: Binding(
                    get: { isNewEntryMode ? tempNote : quote!.note },
                    set: { val in if isNewEntryMode { tempNote = val } else { quote!.note = val } }
                ))
                .fontDesign(.serif)
                .font(.body)
                .italic()
                .multilineTextAlignment(.center)
                .foregroundColor(textColor.opacity(0.6))
                .tint(textColor)
                .focused($isFocused)
                
                Spacer()
            }
            // Force full height to ensure centering
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 3. LIQUID TOOLBAR (Split)
            VStack {
                Spacer()
                
                HStack {
                    // LEFT GROUP: [Edit | Save | Grid]
                    HStack(spacing: 20) {
                        // Edit / Keyboard Toggle
                        Button { isFocused.toggle() } label: {
                            Image(systemName: isFocused ? "keyboard.chevron.compact.down" : "pencil")
                        }
                        
                        // Save (Only active if text exists)
                        Button(action: saveAction) {
                            Image(systemName: showSaveFeedback ? "checkmark" : "arrow.up.circle")
                        }
                        .disabled(isNewEntryMode && tempText.isEmpty)
                        .opacity((isNewEntryMode && tempText.isEmpty) ? 0.4 : 1.0)
                        
                        // Grid / Library
                        NavigationLink(destination: QuoteListView()) {
                            Image(systemName: "square.grid.2x2")
                        }
                    }
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(textColor)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    // RIGHT GROUP: [Share]
                    Button(action: { /* Share Logic Placeholder */ }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 22, weight: .light))
                            .foregroundColor(textColor)
                            .padding(14)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            
            // 4. FEEDBACK OVERLAY
            if showSaveFeedback {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(textColor.opacity(0.8))
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(100)
            }
        }
        // GESTURES
        .simultaneousGesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    
                    // Horizontal Swipe: Color Change
                    if abs(horizontal) > abs(vertical) {
                        let direction = horizontal < 0 ? 1 : -1
                        changeColor(direction: direction)
                    }
                    // Vertical Swipe Up (Save): Only for New Entry
                    else if vertical < -100 && isNewEntryMode {
                        saveAction()
                    }
                }
        )
    }
    
    // --- LOGIC ---
    
    func changeColor(direction: Int) {
        withAnimation {
            let count = backgroundColors.count
            let current = isNewEntryMode ? tempColorIndex : (quote!.colorIndex)
            
            // Modulo loop logic
            var newIndex = current + direction
            if newIndex < 0 { newIndex = count - 1 }
            else if newIndex >= count { newIndex = 0 }
            
            if isNewEntryMode {
                tempColorIndex = newIndex
            } else {
                quote!.colorIndex = newIndex
            }
        }
    }
    
    func saveAction() {
        // Only save if we have text and we are in new mode
        // (Editing existing quotes saves automatically via binding)
        if isNewEntryMode {
            guard !tempText.isEmpty else { return }
            
            let newQuote = Quote(text: tempText, note: tempNote, colorIndex: tempColorIndex)
            modelContext.insert(newQuote)
            
            // Visual Reset
            withAnimation { showSaveFeedback = true }
            tempText = ""
            tempNote = ""
            isFocused = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation { showSaveFeedback = false }
            }
        } else {
            // For existing quotes, just show feedback
            withAnimation { showSaveFeedback = true }
            isFocused = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation { showSaveFeedback = false }
            }
        }
    }
}
