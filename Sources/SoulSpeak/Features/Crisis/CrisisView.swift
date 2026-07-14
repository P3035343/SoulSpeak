import SwiftUI

struct CrisisView: View {
    @State private var contacts: [CrisisContact] = []
    private let crisisService = LocalCrisisDetectionService()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    urgentBanner
                    hotlinesSection
                    copingStrategiesSection
                    personalContactsSection
                }
                .padding()
            }
            .background(SSColors.background)
            .navigationTitle("Crisis Support")
            .task {
                contacts = (try? await crisisService.getCrisisContacts()) ?? crisisService.getDefaultHotlines()
            }
        }
    }
    
    private var urgentBanner: some View {
        SSCard(cornerRadius: 16) {
            VStack(spacing: 12) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(SSColors.error)
                Text("You Are Not Alone")
                    .font(SSTypography.title2)
                    .foregroundColor(SSColors.textPrimary)
                Text("If you are in immediate danger, please call 911 or your local emergency number.")
                    .font(SSTypography.body)
                    .foregroundColor(SSColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var hotlinesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Crisis Hotlines")
                .font(SSTypography.headline)
            ForEach(contacts.filter { $0.isHotline }) { contact in
                SSCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(contact.name)
                                .font(SSTypography.headline)
                            Text(contact.availableHours ?? "24/7")
                                .font(SSTypography.caption)
                                .foregroundColor(SSColors.textSecondary)
                        }
                        Spacer()
                        Link(destination: URL(string: "tel:\(contact.phoneNumber)")!) {
                            Image(systemName: "phone.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(SSColors.success)
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
    }
    
    private var copingStrategiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Coping Strategies")
                .font(SSTypography.headline)
            SSCard {
                VStack(alignment: .leading, spacing: 8) {
                    CopingItem(icon: "wind", text: "Take slow, deep breaths")
                    CopingItem(icon: "figure.walk", text: "Go for a short walk")
                    CopingItem(icon: "drop.fill", text: "Splash cold water on your face")
                    CopingItem(icon: "hand.raised.fill", text: "Name 5 things you can see")
                    CopingItem(icon: "person.2.fill", text: "Reach out to someone you trust")
                }
            }
        }
    }
    
    private var personalContactsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personal Contacts")
                .font(SSTypography.headline)
            ForEach(contacts.filter { !$0.isHotline }) { contact in
                SSCard {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(contact.name)
                                .font(SSTypography.headline)
                            Text(contact.relationship)
                                .font(SSTypography.caption)
                                .foregroundColor(SSColors.textSecondary)
                        }
                        Spacer()
                        Link(destination: URL(string: "tel:\(contact.phoneNumber)")!) {
                            Image(systemName: "phone.fill")
                                .foregroundColor(SSColors.primary)
                        }
                    }
                }
            }
        }
    }
}

struct CopingItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(SSColors.primary)
                .frame(width: 24)
            Text(text)
                .font(SSTypography.body)
                .foregroundColor(SSColors.textPrimary)
        }
    }
}
