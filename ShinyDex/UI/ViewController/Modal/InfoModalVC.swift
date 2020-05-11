//
//  InfoModalVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 05/12/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class InfoModalVC: UIViewController, UIAdaptivePresentationControllerDelegate
{
	@IBOutlet weak var gameSettingsContainer: GameSettingsContainer!
	@IBOutlet weak var scrollView: UIScrollView!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()

		presentationController?.delegate = self

		scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: gameSettingsContainer.topAnchor, constant: 8.0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: gameSettingsContainer.bottomAnchor, constant: -8.0).isActive = true
		
		setClearBackground()
		
		roundViewCorner()
    }
	
	fileprivate func setClearBackground()
	{
		view.backgroundColor = .clear
	}
	
	fileprivate func roundViewCorner()
	{
		gameSettingsContainer.layer.cornerRadius = 10
	}

	func presentationControllerWillDismiss(_ presentationController: UIPresentationController)
	{
		performSegue(withIdentifier: "infoUnwind", sender: self)
	}
}
