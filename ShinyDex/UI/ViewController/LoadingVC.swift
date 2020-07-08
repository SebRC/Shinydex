//
//  LoadingVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 28/09/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class LoadingVC: UIViewController
{
	@IBOutlet weak var loadingLabel: UILabel!
	var pokemonService = PokemonService()
	var colorService = ColorService()
	var fontSettingsService = FontSettingsService()
	var isFirstTimeUser: Bool!
	var loadingGifData: Data?
	var pokeballGifData: Data?
	
	override func viewDidLoad()
	{
        super.viewDidLoad()

		view.backgroundColor = colorService.getSecondaryColor()
		loadingLabel.textColor = colorService.getTertiaryColor()
		loadingLabel.font = fontSettingsService.getMediumFont()
		
		resolveUserStatus()
		
		hideNavigationBar()
		
		if isFirstTimeUser
		{
			proceedAsNewUser()
		}
		else
		{
			proceedAsExistingUser()
		}
    }
	
	fileprivate func resolveUserStatus()
	{
		let allPokemon = pokemonService.getAll()
		isFirstTimeUser = allPokemon.count == 0
	}
	
	fileprivate func hideNavigationBar()
	{
		navigationController?.isNavigationBarHidden = true
	}
	
	fileprivate func proceedAsNewUser()
	{
		pokemonService.populateDatabase()
		performSegue(withIdentifier: "loadSegue", sender: self)
	}
	
	fileprivate func proceedAsExistingUser()
	{
		performSegue(withIdentifier: "loadSegue", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		let destVC = segue.destination as? MenuTVC
		destVC?.pokemonService = pokemonService
	}
}
