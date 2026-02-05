import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 16) {
            // Custom loading indicator
            ZStack {
                Circle()
                    .stroke(Color("AccentOrange").opacity(0.3), lineWidth: 4)
                    .frame(width: 50, height: 50)

                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color("AccentOrange"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            }

            Text("Loading...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.secondaryTextColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isAnimating = true
        }
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(Color("AccentOrange"))

            Text("Something went wrong")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(themeManager.primaryTextColor)

            Text(message)
                .font(.system(size: 14))
                .foregroundColor(themeManager.secondaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: retryAction) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color("AccentOrange"))
                .cornerRadius(8)
            }

            Spacer()
        }
    }
}

#Preview("Loading") {
    LoadingView()
        .environmentObject(ThemeManager())
}

#Preview("Error") {
    ErrorView(message: "Network connection failed") {
        print("Retry")
    }
    .environmentObject(ThemeManager())
}
