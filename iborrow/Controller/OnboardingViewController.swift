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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playVideo()
    }

    private func playVideo() {
        guard let path = Bundle.main.path(forResource: "video", ofType:"m4v") else {
            debugPrint("video.m4v not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
}
