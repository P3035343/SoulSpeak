import SwiftUI

/// Ethiopian Bible Audio — Free clickable audio chapters.
/// The Ethiopian Bible (Ge'ez Canon) contains 81 books.
/// User can tap any chapter to listen.
///
/// Audio files expected: ethiopian_bible_ch1.mp3, ethiopian_bible_ch2.mp3, etc.
/// Or a single long file: ethiopian_bible_full.mp3
struct EthiopianBibleView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioPlayer = AudioPlayerService.shared
    @State private var currentlyPlaying: Int? = nil
    @State private var selectedBook: EthiopianBook = .enoch

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.08, blue: 0.04),
                        Color(red: 0.15, green: 0.1, blue: 0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Book selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(EthiopianBook.allCases, id: \.self) { book in
                                bookPill(book)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }

                    // Chapter list
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            // Book description
                            Text(selectedBook.description)
                                .font(.system(size: 13, weight: .regular, design: .serif))
                                .foregroundColor(.white.opacity(0.6))
                                .italic()
                                .padding(.horizontal, 20)
                                .padding(.bottom, 8)

                            ForEach(1...selectedBook.chapters, id: \.self) { chapter in
                                chapterRow(chapter)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Ethiopian Bible")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }

    // MARK: - Book Pill
    private func bookPill(_ book: EthiopianBook) -> some View {
        Button(action: { selectedBook = book }) {
            Text(book.rawValue)
                .font(.system(size: 13, weight: selectedBook == book ? .bold : .medium))
                .foregroundColor(selectedBook == book ? .black : .white.opacity(0.7))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(selectedBook == book ? Color(red: 0.85, green: 0.7, blue: 0.3) : Color.white.opacity(0.08))
                )
        }
    }

    // MARK: - Chapter Row
    private func chapterRow(_ chapter: Int) -> some View {
        Button(action: { playChapter(chapter) }) {
            HStack(spacing: 14) {
                // Chapter number
                ZStack {
                    Circle()
                        .fill(currentlyPlaying == chapter ? Color(red: 0.85, green: 0.7, blue: 0.3).opacity(0.2) : Color.white.opacity(0.06))
                        .frame(width: 44, height: 44)

                    if currentlyPlaying == chapter {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.85, green: 0.7, blue: 0.3))
                    } else {
                        Text("\(chapter)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(selectedBook.rawValue) — Chapter \(chapter)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)

                    Text("Tap to listen")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.4))
                }

                Spacer()

                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 12))
                    .foregroundColor(currentlyPlaying == chapter ? Color(red: 0.85, green: 0.7, blue: 0.3) : .white.opacity(0.2))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(currentlyPlaying == chapter ? Color(red: 0.85, green: 0.7, blue: 0.3).opacity(0.06) : Color.white.opacity(0.02))
            )
        }
    }

    // MARK: - Play Chapter
    private func playChapter(_ chapter: Int) {
        if currentlyPlaying == chapter {
            audioPlayer.stopAll()
            currentlyPlaying = nil
        } else {
            audioPlayer.stopAll()
            // File naming: ethiopian_bible_[book]_ch[number]
            let fileName = "ethiopian_bible_\(selectedBook.filePrefix)_ch\(chapter)"
            audioPlayer.playVoice(fileName: fileName)
            currentlyPlaying = chapter
        }
    }
}

// MARK: - Ethiopian Bible Books
enum EthiopianBook: String, CaseIterable {
    case enoch = "Book of Enoch"
    case jubilees = "Jubilees"
    case meqabyan1 = "1 Meqabyan"
    case meqabyan2 = "2 Meqabyan"
    case meqabyan3 = "3 Meqabyan"
    case sirach = "Sirach"
    case tobit = "Tobit"
    case judith = "Judith"
    case wisdom = "Wisdom"
    case baruch = "Baruch"

    var chapters: Int {
        switch self {
        case .enoch: return 36
        case .jubilees: return 50
        case .meqabyan1: return 36
        case .meqabyan2: return 10
        case .meqabyan3: return 10
        case .sirach: return 51
        case .tobit: return 14
        case .judith: return 16
        case .wisdom: return 19
        case .baruch: return 6
        }
    }

    var filePrefix: String {
        switch self {
        case .enoch: return "enoch"
        case .jubilees: return "jubilees"
        case .meqabyan1: return "meqabyan1"
        case .meqabyan2: return "meqabyan2"
        case .meqabyan3: return "meqabyan3"
        case .sirach: return "sirach"
        case .tobit: return "tobit"
        case .judith: return "judith"
        case .wisdom: return "wisdom"
        case .baruch: return "baruch"
        }
    }

    var description: String {
        switch self {
        case .enoch: return "The Book of Enoch describes the fall of the Watchers, angels who fathered the Nephilim, and Enoch's journeys through heaven."
        case .jubilees: return "Also called 'Little Genesis' — retells Genesis and Exodus with additional details and a 364-day calendar."
        case .meqabyan1: return "Ethiopian books not found in other biblical canons. Focuses on themes of faith under persecution."
        case .meqabyan2: return "Continuation of spiritual warfare and faithfulness under trial."
        case .meqabyan3: return "Concluding volume of the Meqabyan series unique to the Ethiopian canon."
        case .sirach: return "Wisdom literature — practical teachings on ethics, relationships, and devotion to God."
        case .tobit: return "Story of Tobit and his son Tobias — themes of faith, healing, and angelic guidance."
        case .judith: return "The heroic story of Judith saving Israel through courage and faith."
        case .wisdom: return "The Wisdom of Solomon — reflections on righteousness, immortality, and divine wisdom."
        case .baruch: return "Written by Baruch, scribe of Jeremiah — prayers and reflections during exile."
        }
    }
}
