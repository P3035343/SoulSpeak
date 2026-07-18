#!/usr/bin/env swift
/// SoulSpeak App Icon Generator
/// Run this script on macOS to generate the app icon:
///   swift Scripts/GenerateAppIcon.swift
///
/// It generates a 1024x1024 PNG app icon with:
/// - Deep purple-to-dark gradient background
/// - Golden spiritual glow circle
/// - Stylized "S" letter in white
/// - Sound wave arcs (representing voice/speak)
/// - "SoulSpeak" tagline at bottom

import Foundation
import CoreGraphics
import CoreText
import ImageIO

let size: Int = 1024
let cgSize = CGFloat(size)
let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

guard let context = CGContext(
    data: nil,
    width: size,
    height: size,
    bitsPerComponent: 8,
    bytesPerRow: size * 4,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    fatalError("Failed to create CGContext")
}

// === BACKGROUND GRADIENT ===
let bgColors = [
    CGColor(red: 0.28, green: 0.18, blue: 0.55, alpha: 1.0),
    CGColor(red: 0.15, green: 0.10, blue: 0.35, alpha: 1.0),
    CGColor(red: 0.08, green: 0.06, blue: 0.20, alpha: 1.0)
] as CFArray

let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0.0, 0.5, 1.0])!
context.drawLinearGradient(
    bgGradient,
    start: CGPoint(x: 0, y: cgSize),
    end: CGPoint(x: cgSize, y: 0),
    options: []
)

// === GOLDEN GLOW ===
let centerX = cgSize / 2.0
let centerY = cgSize / 2.0 + 20

let glowColors = [
    CGColor(red: 0.95, green: 0.75, blue: 0.25, alpha: 0.35),
    CGColor(red: 0.90, green: 0.65, blue: 0.15, alpha: 0.15),
    CGColor(red: 0.85, green: 0.55, blue: 0.10, alpha: 0.0)
] as CFArray
let glowGradient = CGGradient(colorsSpace: colorSpace, colors: glowColors, locations: [0.0, 0.5, 1.0])!

context.drawRadialGradient(
    glowGradient,
    startCenter: CGPoint(x: centerX, y: centerY),
    startRadius: 80,
    endCenter: CGPoint(x: centerX, y: centerY),
    endRadius: 400,
    options: []
)

// === SOUND WAVE ARCS ===
context.setLineCap(.round)
context.setLineJoin(.round)

// Left arcs
for i in 0..<3 {
    let radius: CGFloat = CGFloat(130 + i * 65)
    let alpha = CGFloat(3 - i) / 4.0 + 0.15
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: alpha))
    context.setLineWidth(CGFloat(16 - i * 2))

    let arcCenter = CGPoint(x: centerX - 30, y: centerY - 30)
    context.addArc(center: arcCenter, radius: radius, startAngle: .pi * 1.2, endAngle: .pi * 1.8, clockwise: false)
    context.strokePath()
}

// Right arcs
for i in 0..<3 {
    let radius: CGFloat = CGFloat(130 + i * 65)
    let alpha = CGFloat(3 - i) / 4.0 + 0.15
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: alpha))
    context.setLineWidth(CGFloat(16 - i * 2))

    let arcCenter = CGPoint(x: centerX + 30, y: centerY - 30)
    context.addArc(center: arcCenter, radius: radius, startAngle: .pi * 0.2, endAngle: -.pi * 0.2, clockwise: true)
    context.strokePath()
}

// === CENTRAL "S" LETTER ===
let font = CTFontCreateWithName("Georgia-Bold" as CFString, 380, nil)
let attrs: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95)
]
let attrStr = NSAttributedString(string: "S", attributes: attrs)
let line = CTLineCreateWithAttributedString(attrStr)
let textBounds = CTLineGetBoundsWithOptions(line, [])

context.textPosition = CGPoint(
    x: centerX - textBounds.width / 2.0 - 10,
    y: centerY - textBounds.height / 2.0 - 40
)
CTLineDraw(line, context)

// === "SoulSpeak" TAGLINE ===
let tagFont = CTFontCreateWithName("Avenir-Medium" as CFString, 80, nil)
let tagAttrs: [NSAttributedString.Key: Any] = [
    .font: tagFont,
    .foregroundColor: CGColor(red: 0.95, green: 0.78, blue: 0.30, alpha: 0.85)
]
let tagStr = NSAttributedString(string: "SoulSpeak", attributes: tagAttrs)
let tagLine = CTLineCreateWithAttributedString(tagStr)
let tagBounds = CTLineGetBoundsWithOptions(tagLine, [])

context.textPosition = CGPoint(x: centerX - tagBounds.width / 2.0, y: 110)
CTLineDraw(tagLine, context)

// === EXPORT PNG ===
guard let image = context.makeImage() else {
    fatalError("Failed to create image")
}

let scriptDir = URL(fileURLWithPath: #file).deletingLastPathComponent()
let projectRoot = scriptDir.deletingLastPathComponent()
let outputPath = projectRoot.appendingPathComponent("SoulSpeak/Assets.xcassets/AppIcon.appiconset/AppIcon.png")

guard let dest = CGImageDestinationCreateWithURL(outputPath as CFURL, "public.png" as CFString, 1, nil) else {
    fatalError("Failed to create output file")
}
CGImageDestinationAddImage(dest, image, nil)

if CGImageDestinationFinalize(dest) {
    print("App icon generated successfully!")
    print("Location: \(outputPath.path)")
} else {
    fatalError("Failed to write PNG")
}
