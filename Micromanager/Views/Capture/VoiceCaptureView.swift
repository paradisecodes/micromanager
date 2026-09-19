import SwiftUI

/// Voice-first capture sheet. Recording and live on-device transcription are
/// real (see `SpeechTranscriber`). What's not built yet: parsing that free
/// text into multiple, differently-categorized blocks — that needs an NLP/AI
/// step the PRD hasn't settled on. Until then, the whole captured period gets
/// a single category/subcategory assignment.
struct VoiceCaptureView: View {
    let referenceDate: Date
    @Environment(\.dismiss) private var dismiss
    @Environment(AuditStore.self) private var store
    @State private var transcriber = SpeechTranscriber()
    @State private var selectedCategory: TimeCategory?
    @State private var selectedSubcategory: Subcategory?
    @State private var isPickingManually = false

    private var captureRange: (startSlot: Int, endSlot: Int) {
        let c = Calendar.current
        let endSlot = c.component(.hour, from: referenceDate) * TimeBlock.blocksPerHour + c.component(.minute, from: referenceDate) / 15
        return (max(0, endSlot - 4), endSlot)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") { transcriber.stop(); dismiss() }
                    .font(.dsMedium(16))
                    .foregroundStyle(Color.dsOnIndigoTertiary)
                Spacer()
                Text(hourRangeText).font(.dsSemiBold(15)).foregroundStyle(.white)
                Spacer()
                Button("Save") { save() }
                    .font(.dsSemiBold(16))
                    .foregroundStyle(selectedCategory == nil ? .white.opacity(0.35) : .white)
                    .disabled(selectedCategory == nil)
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)

            VStack(spacing: 14) {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array(transcriber.audioLevels.enumerated()), id: \.offset) { _, level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(level > 0.55 ? Color.dsMint : Color.dsIndigoPale)
                            .frame(width: 4, height: max(4, CGFloat(level) * 52))
                    }
                }
                .frame(height: 52)
                .animation(.linear(duration: 0.1), value: transcriber.audioLevels)

                Button {
                    toggleRecording()
                } label: {
                    Circle()
                        .fill(.white)
                        .frame(width: 92, height: 92)
                        .overlay(Circle().stroke(.white.opacity(0.12), lineWidth: 10).padding(-10))
                        .overlay(Image(systemName: transcriber.isRecording ? "stop.fill" : "mic.fill").font(.system(size: 30)).foregroundStyle(Color.dsIndigo))
                }
                Text(statusText)
                    .font(.dsMedium(15))
                    .foregroundStyle(Color.dsOnIndigoSecondary)
            }
            .padding(.top, 18)

            Text(transcriber.transcript.isEmpty ? "Say what you did\u{2026}" : transcriber.transcript)
                .font(.dsRegular(17))
                .foregroundStyle(transcriber.transcript.isEmpty ? Color.dsOnIndigoTertiary : .white)
                .frame(minHeight: 60, alignment: .topLeading)
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.horizontal, 22)
                .padding(.top, 18)

            assignmentSheet
        }
        .background(Color.dsIndigo)
        .onAppear { requestAndStart() }
        .onDisappear { transcriber.stop() }
        .sheet(isPresented: $isPickingManually, onDismiss: { dismiss() }) {
            ManualBlockFillView(entry: TimelineEntry(startSlot: captureRange.startSlot, endSlot: captureRange.endSlot, categoryID: nil, subcategoryID: nil), date: referenceDate)
        }
    }

    private var assignmentSheet: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .lastTextBaseline) {
                Text("WHAT WAS THIS?").font(.dsSemiBold(13)).tracking(0.8).foregroundStyle(Color.dsTextTertiary)
                Spacer()
            }

            if let errorMessage = transcriber.errorMessage {
                Text(errorMessage).font(.dsRegular(14)).foregroundStyle(Color.dsTextSecondary)
            }
            if transcriber.authorizationState == .denied {
                Text("Speech recognition access was denied. Enable it in Settings to use voice capture.")
                    .font(.dsRegular(14)).foregroundStyle(Color.dsTextSecondary)
            }

            categoryMenu

            Spacer(minLength: 0)

            VStack(spacing: 10) {
                Button { save() } label: {
                    DSPrimaryButton(title: saveTitle)
                        .opacity(selectedCategory == nil ? 0.5 : 1)
                }
                .disabled(selectedCategory == nil)
                Button("Enter manually instead") { transcriber.stop(); isPickingManually = true }
                    .font(.dsMedium(15))
                    .foregroundStyle(Color.dsTextSecondary)
            }
            .padding(.bottom, 14)
        }
        .padding(.horizontal, 22)
        .padding(.top, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.dsBackground)
        .clipShape(.rect(topLeadingRadius: 28, topTrailingRadius: 28))
        .padding(.top, 16)
    }

    private var categoryMenu: some View {
        Menu {
            ForEach(store.categories.filter { !$0.isSystemDefault }) { category in
                if category.subcategories.isEmpty {
                    Button(category.name) { selectedCategory = category; selectedSubcategory = nil }
                } else {
                    Menu(category.name) {
                        ForEach(category.subcategories) { sub in
                            Button(sub.name) { selectedCategory = category; selectedSubcategory = sub }
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(selectedCategory.map { Color(hex: $0.colorHex) } ?? Color.dsTrack)
                    .frame(width: 10, height: 10)
                VStack(alignment: .leading, spacing: 0) {
                    Text(selectedSubcategory?.name ?? selectedCategory?.name ?? "Choose a category")
                        .font(.dsSemiBold(16))
                        .foregroundStyle(Color.dsTextPrimary)
                    if let selectedCategory, selectedSubcategory != nil {
                        Text(selectedCategory.name).font(.dsRegular(13)).foregroundStyle(Color.dsTextTertiary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.up.chevron.down").font(.system(size: 12, weight: .bold)).foregroundStyle(Color.dsChevron)
            }
            .padding(13)
            .background(Color.dsCard)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.dsChrome.opacity(0.05), radius: 1, x: 0, y: 1)
        }
    }

    private func requestAndStart() {
        transcriber.requestAuthorization { granted in
            if granted { transcriber.start() }
        }
    }

    private func toggleRecording() {
        if transcriber.isRecording {
            transcriber.stop()
        } else {
            transcriber.start()
        }
    }

    private func save() {
        guard let selectedCategory else { return }
        transcriber.stop()
        for slot in captureRange.startSlot..<captureRange.endSlot {
            store.setBlock(categoryID: selectedCategory.id, subcategoryID: selectedSubcategory?.id, forSlot: slot, on: referenceDate)
        }
        dismiss()
    }

    private var statusText: String {
        if transcriber.isRecording { return "Listening \u{2014} tap to stop" }
        return transcriber.transcript.isEmpty ? "Tap to start listening" : "Stopped \u{2014} tap to record more"
    }

    private var saveTitle: String {
        let count = captureRange.endSlot - captureRange.startSlot
        return "Save \(count) block\(count == 1 ? "" : "s")"
    }

    private var hourRangeText: String {
        let start = Calendar.current.date(byAdding: .hour, value: -1, to: referenceDate) ?? referenceDate
        return "\(start.formatted(.dateTime.hour().minute())) \u{2013} \(referenceDate.formatted(.dateTime.hour().minute()))"
    }
}

#Preview {
    VoiceCaptureView(referenceDate: .now)
        .environment(AuditStore.preview())
}
