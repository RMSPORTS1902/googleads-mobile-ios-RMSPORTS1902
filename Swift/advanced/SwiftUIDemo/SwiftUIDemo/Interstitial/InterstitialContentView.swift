import GoogleMobileAds
import SwiftUI

struct InterstitialContentView: View {
  @StateObject private var countdownTimer = CountdownTimer()
  @State private var showGameOverAlert = false
  private let coordinator = InterstitialAdCoordinator()
  let navigationTitle: String

  var body: some View {
    VStack(spacing: 20) {
      Text("The Impossible Game")
        .font(.largeTitle)

      Spacer()

      Text("\(countdownTimer.timeLeft) seconds left!")
        .font(.title2)

      Button("Play Again") {
        startNewGame()
      }
      .font(.title2)
      .opacity(countdownTimer.isComplete ? 1 : 0)

      Spacer()
    }
    .onAppear {
      if !countdownTimer.isComplete {
        startNewGame()
      }
    }
    .onDisappear {
      countdownTimer.pause()
    }
    .onChange(of: countdownTimer.isComplete) { newValue in
      showGameOverAlert = newValue
    }
    .alert(isPresented: $showGameOverAlert) {
      Alert(
        title: Text("Game Over"),
        message: Text("You lasted \(countdownTimer.countdownTime) seconds"),
        dismissButton: .cancel(
          Text("OK"),
          action: {
            coordinator.showAd()
          }))
    }
    .navigationTitle(navigationTitle)
  }

  private func startNewGame() {
    coordinator.loadAd()

    countdownTimer.start()
  }
}

struct InterstitialContentView_Previews: PreviewProvider {
  static var previews: some View {
    InterstitialContentView(navigationTitle: "Interstitial")
  }
}

private class InterstitialAdCoordinator: NSObject, GADFullScreenContentDelegate {
  private var interstitial: GADInterstitialAd?

  func loadAd() {
    GADInterstitialAd.load(
      withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest()
    ) { ad, error in
      self.interstitial = ad
      self.interstitial?.fullScreenContentDelegate = self
    }
  }

  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    interstitial = nil
  }

  func showAd() {
    guard let interstitial = interstitial else {
      return print("Ad wasn't ready")
    }

    interstitial.present(fromRootViewController: nil)
  }
}
