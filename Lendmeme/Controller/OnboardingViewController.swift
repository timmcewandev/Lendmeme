//
//  OnboardingViewController.swift
//  iborrow
//
//  Created by Tim on 4/13/20.
//  Copyright © 2020 sudo. All rights reserved.
//

import UIKit
import UIKit
import AVKit
import AVFoundation

class OnboardingViewController: UIViewController {
    var hasSeenOnboarding = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if hasSeenOnboarding == true {
            self.dismiss(animated: true) {
                self.hasSeenOnboarding = false
            }
        } else {
           playVideo()
        }
        
    }

    private func playVideo() {
        guard let path = Bundle.main.path(forResource: "LendmemeDirectional", ofType:".mov") else {
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
            self.hasSeenOnboarding = true
        }
    }
}
