import SwiftUI

struct TodayView: View {
    @Environment(AuditStore.self) private var store
    @State private var now: Date = .now
    @State private var isPresentingCapture = false
    @State private var isPresentingCheckIn = false
    @State private var catchUpEntry: TimelineEntry?

    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    private var currentSlot: Int {
        let c = Calendar.current
        return c.component(.hour, from: now) * TimeBlock.blocksPerHour + c.component(.minute, from: now) / 15
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    progressStrip
                    liveBlockCard
                    timelineHeader
                    timelineList
                }
            }
            .background(Color.dsBackground)
            .navigationBarHidden(true)
            .onReceive(timer) { now = $0 }
            .sheet(isPresented: $isPresentingCapture) {
                VoiceCaptureView(referenceDate: now)
            }
            .sheet(item: $catchUpEntry) { entry in
                CatchUpView(entry: entry, date: now)
            }
            .sheet(isPresented: $isPresentingCheckIn) {
                CheckInView()
            }
            .onAppear {
                #if DEBUG
                let args = ProcessInfo.processInfo.arguments
                if args.contains("-showCapture") { isPresentingCapture = true }
                if args.contains("-showCheckIn") { isPresentingCheckIn = true }
                if args.contains("-showCatchUp") { catchUpEntry = store.timeline(for: now, upToSlot: currentSlot).first { $0.isGap } }
                #endif
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(now.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                    .font(.dsSemiBold(13))
                    .tracking(0.8)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.dsTextTertiary)
                Text(store.dayNumber(for: now).map { "Day \($0) of 14" } ?? "No audit yet")
                    .font(.dsSemiBold(30))
                    .foregroundStyle(Color.dsTextPrimary)
            }
            Spacer()
            Circle()
                .fill(Color.dsTint)
                .frame(width: 38, height: 38)
                .overlay(Text("MP").font(.dsSemiBold(14)).foregroundStyle(Color.dsIndigo))
        }
        .padding(.horizontal, 22)
        .padding(.top, 14)
    }

    private var progressStrip: some View {
        HStack(spacing: 5) {
            ForEach(Array(store.progressStrip(referenceDate: now).enumerated()), id: \.offset) { _, state in
                RoundedRectangle(cornerRadius: 3)
                    .fill(state == true ? Color.dsIndigo : state == nil ? Color.dsIndigoLight : Color.dsTrack)
                    .frame(height: 5)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 14)
    }

    private var liveBlockCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Circle().fill(Color.dsMint).frame(width: 8, height: 8)
                    Text("HAPPENING NOW")
                        .font(.dsSemiBold(13))
                        .tracking(0.8)
                        .foregroundStyle(Color.dsOnIndigoSecondary)
                }
                Spacer()
                Text(currentSlotRangeText)
                    .font(.dsMedium(13))
                    .foregroundStyle(Color.dsOnIndigoSecondary)
            }
            Text("You're \(minutesIntoCurrentBlock) minutes into an untracked block.")
                .font(.dsSemiBold(22))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Button {
                    isPresentingCapture = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "mic.fill")
                        Text("Log it now")
                    }
                    .font(.dsSemiBold(16))
                    .foregroundStyle(Color.dsIndigo)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                Button {} label: {
                    Image(systemName: "clock")
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.35), lineWidth: 1.5))
                }
            }
            Text("Next prompt at \(nextPromptText)")
                .font(.dsMedium(13.5))
                .foregroundStyle(Color.dsOnIndigoTertiary)
        }
        .padding(20)
        .background(Color.dsIndigo)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .padding(.horizontal, 22)
        .padding(.top, 18)
    }

    private var timelineHeader: some View {
        HStack(alignment: .lastTextBaseline) {
            Text("Today so far").font(.dsSemiBold(19)).foregroundStyle(Color.dsTextPrimary)
            Spacer()
            Text("Edit").font(.dsSemiBold(14)).foregroundStyle(Color.dsIndigo)
        }
        .padding(.horizontal, 22)
        .padding(.top, 22)
        .padding(.bottom, 10)
    }

    private var timelineList: some View {
        VStack(spacing: 8) {
            ForEach(store.timeline(for: now, upToSlot: currentSlot)) { entry in
                if entry.isGap {
                    gapRow(entry)
                } else {
                    entryRow(entry)
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 24)
    }

    private func entryRow(_ entry: TimelineEntry) -> some View {
        let category = store.category(withID: entry.categoryID)
        let subcategory = store.subcategory(withID: entry.subcategoryID, in: category)
        return HStack(spacing: 13) {
            Text(slotLabel(entry.startSlot))
                .font(.dsSemiBold(13))
                .foregroundStyle(Color.dsTextTertiary)
                .frame(width: 46, alignment: .leading)
            RoundedRectangle(cornerRadius: 2)
                .fill(category.map { Color(hex: $0.colorHex) } ?? Color.dsTrack)
                .frame(width: 4, height: 26)
            VStack(alignment: .leading, spacing: 0) {
                Text(subcategory?.name ?? category?.name ?? "Unassigned")
                    .font(.dsSemiBold(16))
                    .foregroundStyle(Color.dsTextPrimary)
                if let category, subcategory != nil {
                    Text(category.name).font(.dsRegular(13)).foregroundStyle(Color.dsTextTertiary)
                }
            }
            Spacer()
            Text(durationLabel(entry.durationMinutes))
                .font(.dsMedium(14))
                .foregroundStyle(Color.dsTextSecondary)
        }
        .padding(13)
        .background(Color.dsCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.dsChrome.opacity(0.05), radius: 1, x: 0, y: 1)
    }

    private func gapRow(_ entry: TimelineEntry) -> some View {
        HStack(spacing: 13) {
            Text(slotLabel(entry.startSlot))
                .font(.dsSemiBold(13))
                .foregroundStyle(Color.dsTextTertiary)
                .frame(width: 46, alignment: .leading)
            Text("\(durationLabel(entry.durationMinutes)) unaccounted")
                .font(.dsSemiBold(16))
                .foregroundStyle(Color.dsIndigo)
            Spacer()
            Button("Fill") { catchUpEntry = entry }
                .font(.dsSemiBold(14))
                .foregroundStyle(Color.dsIndigo)
        }
        .padding(13)
        .background(Color.dsTint.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.dsDashedBorder, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])))
    }

    private func slotLabel(_ slot: Int) -> String {
        String(format: "%d:%02d", slot / TimeBlock.blocksPerHour, (slot % TimeBlock.blocksPerHour) * 15)
    }

    private func durationLabel(_ minutes: Int) -> String {
        let h = minutes / 60, m = minutes % 60
        if h == 0 { return "\(m)m" }
        if m == 0 { return "\(h)h" }
        return "\(h)h \(m)m"
    }

    private var currentSlotRangeText: String {
        let startSlot = currentSlot - (currentSlot % 1)
        return "\(slotLabel(startSlot)) – \(slotLabel(startSlot + 1))"
    }

    private var minutesIntoCurrentBlock: Int {
        Calendar.current.component(.minute, from: now) % 15
    }

    private var nextPromptText: String {
        let nextHour = (Calendar.current.component(.hour, from: now) + 1) % 24
        return String(format: "%d:00", nextHour)
    }
}

#Preview {
    TodayView()
        .environment(AuditStore.preview())
}
