import AVFoundation
import CoreImage
import AppKit

// 종이 배경을 순백으로 평탄화한다. 선(잉크)은 그대로 둔다.
let ctx = CIContext(options: [.workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!])
func flatten(_ img: CIImage, scale: CGFloat) -> CIImage {
  let ext = img.extent
  let clamped = img.clampedToExtent()
  let bg = clamped
    .applyingFilter("CIMorphologyMaximum", parameters: ["inputRadius": 14 * scale])
    .applyingFilter("CIGaussianBlur", parameters: ["inputRadius": 40 * scale])
  // background / input  → 종이는 1.0 근처
  let ratio = img.applyingFilter("CIDivideBlendMode", parameters: ["inputBackgroundImage": img, "inputImage": bg]).cropped(to: ext)
  // levels: 0.90 이상은 흰색으로
  let s: CGFloat = 1 / 0.90
  let lv = ratio.applyingFilter("CIColorMatrix", parameters: [
    "inputRVector": CIVector(x: s, y: 0, z: 0, w: 0),
    "inputGVector": CIVector(x: 0, y: s, z: 0, w: 0),
    "inputBVector": CIVector(x: 0, y: 0, z: s, w: 0)])
    .applyingFilter("CIColorClamp")
    .applyingFilter("CIColorControls", parameters: ["inputSaturation": 0])
  return lv.cropped(to: ext)
}
func savePNG(_ img: CIImage, _ path: String) {
  let cg = ctx.createCGImage(img, from: img.extent)!
  try! NSBitmapImageRep(cgImage: cg).representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
}

let args = CommandLine.arguments
let src = URL(fileURLWithPath: args[1]), dst = URL(fileURLWithPath: args[2]), outDir = args[3]
try? FileManager.default.removeItem(at: dst)

// 로고 PNG
let logo = CIImage(contentsOf: URL(fileURLWithPath: args[4]))!
savePNG(flatten(logo, scale: logo.extent.width / 640), outDir + "/logo-flat.png")

let asset = AVURLAsset(url: src)
let track = asset.tracks(withMediaType: .video)[0]
let size = track.naturalSize
let reader = try! AVAssetReader(asset: asset)
let out = AVAssetReaderTrackOutput(track: track, outputSettings: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA])
reader.add(out)
let writer = try! AVAssetWriter(outputURL: dst, fileType: .mp4)
writer.shouldOptimizeForNetworkUse = true
let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
  AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: size.width, AVVideoHeightKey: size.height,
  AVVideoColorPropertiesKey: [AVVideoColorPrimariesKey: AVVideoColorPrimaries_ITU_R_709_2,
    AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2, AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_709_2],
  AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 900_000, AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel]])
input.expectsMediaDataInRealTime = false
let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
  kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA, kCVPixelBufferWidthKey as String: size.width, kCVPixelBufferHeightKey as String: size.height])
writer.add(input)
reader.startReading(); writer.startWriting(); writer.startSession(atSourceTime: .zero)
var n = 0; var last: CIImage?
while let sb = out.copyNextSampleBuffer() {
  let pts = CMSampleBufferGetPresentationTimeStamp(sb)
  let img = flatten(CIImage(cvPixelBuffer: CMSampleBufferGetImageBuffer(sb)!), scale: 1)
  var pb: CVPixelBuffer?
  CVPixelBufferPoolCreatePixelBuffer(nil, adaptor.pixelBufferPool!, &pb)
  ctx.render(img, to: pb!)
  while !input.isReadyForMoreMediaData { usleep(1000) }
  adaptor.append(pb!, withPresentationTime: pts)
  if n == 0 { savePNG(img, outDir + "/first.png") }
  last = img; n += 1
}
savePNG(last!, outDir + "/last.png")
input.markAsFinished()
let sem = DispatchSemaphore(value: 0)
writer.finishWriting { sem.signal() }; sem.wait()
print("frames", n, writer.status.rawValue, writer.error ?? "")
