//
//  SignatureView.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 10/07/25.
//

import SwiftUI
import PencilKit
import UIKit

struct SignatureView: View {
    @EnvironmentObject var viewModel: KYCFormViewModel
    @State private var canvasView = PKCanvasView()
    @State private var showingSavedAlert = false
    @State private var showingClearAlert = false
    
    var body: some View {
        Section("Digital Signature") {
            VStack {
                Text("Please provide your digital signature")
                    .font(.headline)
                    .padding(.bottom)
                
                Text("By signing below, you certify that all information provided is true and accurate.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                
                // Signature Canvas
                SignatureCanvas(canvasView: $canvasView)
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(viewModel.isSignatureValid ? Color.green : Color.gray, lineWidth: 2)
                    )
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                
                // Show signature status
                HStack {
                    if viewModel.isSignatureValid {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Signature captured")
                            .foregroundColor(.green)
                            .font(.caption)
                    } else {
                        Image(systemName: "pencil.circle")
                            .foregroundColor(.gray)
                        Text("Please sign above")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    Spacer()
                }
                .padding(.top, 8)
                
                // Action Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        showingClearAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.red)
                        .cornerRadius(8)
                    }
                    .disabled(canvasView.drawing.strokes.isEmpty)
                    
                    Spacer()
                    
                    Button(action: captureSignature) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Capture")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(canvasView.drawing.strokes.isEmpty ? Color.gray : Color.green)
                        .cornerRadius(8)
                    }
                    .disabled(canvasView.drawing.strokes.isEmpty)
                }
                .padding(.top)
            }
            .padding()
        }
        .alert("Clear Signature", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                eraseSignature()
            }
        } message: {
            Text("Are you sure you want to clear your signature?")
        }
        .alert("Signature Captured", isPresented: $showingSavedAlert) {
            Button("OK") { }
        } message: {
            Text("Your signature has been captured successfully!")
        }
        .onAppear {
            setupCanvas()
            loadExistingSignature()
        }
    }
    
    private func setupCanvas() {
        // Configure the canvas for signature capture
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = UIColor.white
        
        // Set up the drawing tool (black ink pen)
        let ink = PKInk(.pen, color: .black)
        canvasView.tool = PKInkingTool(ink.inkType)
        
        // Disable ruler and other tools
        canvasView.isRulerActive = false
        canvasView.showsVerticalScrollIndicator = false
        canvasView.showsHorizontalScrollIndicator = false
    }
    
    private func eraseSignature() {
        canvasView.drawing = PKDrawing()
        viewModel.digitalSignature.imageData = nil
        viewModel.digitalSignature.isComplete = false
        viewModel.isSignatureValid = false
    }
    
    private func captureSignature() {
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)
        
        if let imageData = image.pngData() {
            viewModel.digitalSignature.imageData = imageData
            viewModel.digitalSignature.timestamp = Date()
            viewModel.digitalSignature.isComplete = true
            viewModel.digitalSignature.userId = viewModel.member.memberId
            viewModel.isSignatureValid = true
            
            showingSavedAlert = true
        }
    }
    
    private func loadExistingSignature() {
        if let imageData = viewModel.digitalSignature.imageData,
           let _ = UIImage(data: imageData),
           let drawingData = try? PKDrawing(data: imageData) {
            canvasView.drawing = drawingData
        }
    }
}

struct SignatureCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = UIColor.white
        canvasView.isOpaque = false
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Updates can be handled here if needed
    }
}


#Preview {
    SignatureView()
}
