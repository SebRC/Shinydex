//
//  ShinyTrackerVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 20/05/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class ShinyTrackerVC: UIViewController
{
	@IBOutlet weak var gifImageView: UIImageView!
	@IBOutlet weak var encountersLabel: UILabel!
	@IBOutlet weak var plusButton: UIButton!
	@IBOutlet weak var minusButton: UIButton!
	@IBOutlet weak var probabilityLabel: UILabel!
	@IBOutlet weak var addToHuntButton: UIBarButtonItem!
	@IBOutlet weak var pokeballButton: UIButton!
	@IBOutlet weak var popupView: PopupView!
	@IBOutlet weak var doubleButtonsVerticalView: DoubleVerticalButtonsView!
	@IBOutlet weak var numberLabel: UILabel!
	@IBOutlet weak var gifSeparatorView: UIView!
	
	var pokemon: Pokemon!
	var resolver = Resolver()
	var probability: Double?
	var shinyProbability: Int!
	var infoPressed = false
	var setEncountersPressed = false
	let popupHandler = PopupHandler()
	var pokemonRepository: PokemonRepository!
	var settingsRepo: SettingsRepository!
	var currentHuntRepo: CurrentHuntRepository!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		hidePopupView()
		
		setUIColors()
		
		roundCorners()
		
		roundDoubleVerticalButtonsViewCorners()
		
		setFonts()
		
		setTitle()
		
		setGif()
	
		resolveEncounterDetails()
		
		setNumberLabelText()
		
		setPokeballButtonImage()
		
		setButtonActions()
		
		addToHuntButton.isEnabled = addToHuntButtonIsEnabled()
	}
	
	fileprivate func hidePopupView()
	{
		popupView.isHidden = true
	}
	
	fileprivate func setPokeballButtonImage()
	{
		pokeballButton.setBackgroundImage(UIImage(named: pokemon.caughtBall), for: .normal)
	}
	
	fileprivate func setUIColors()
	{
		view.backgroundColor = settingsRepo.getMainColor()
		popupView.backgroundColor = settingsRepo.getSecondaryColor()
		
		numberLabel.backgroundColor = settingsRepo.getSecondaryColor()
		encountersLabel.backgroundColor = settingsRepo.getSecondaryColor()
		probabilityLabel.backgroundColor = settingsRepo.getSecondaryColor()
		
		gifSeparatorView.backgroundColor = settingsRepo.getSecondaryColor()
		
		pokeballButton.backgroundColor = settingsRepo.getMainColor()
	}
	
	fileprivate func roundCorners()
	{
		popupView.layer.cornerRadius = 5
		
		numberLabel.layer.cornerRadius = 5
		encountersLabel.layer.cornerRadius = 5
		probabilityLabel.layer.cornerRadius = 5
		
		gifSeparatorView.layer.cornerRadius = 5
		
		pokeballButton.layer.cornerRadius = pokeballButton.bounds.width / 2
	}
	
	fileprivate func roundDoubleVerticalButtonsViewCorners()
	{
		doubleButtonsVerticalView.layer.cornerRadius = 5
	}
	
	fileprivate func setFonts()
	{
		numberLabel.font = settingsRepo.getSmallFont()
		probabilityLabel.font = settingsRepo.getSmallFont()
		encountersLabel.font = settingsRepo.getSmallFont()
		popupView.actionLabel.font = settingsRepo.getSmallFont()
	}
	
	fileprivate func setTitle()
	{
		title = pokemon.name
	}
	
	fileprivate func setGif()
	{
		gifImageView.image = UIImage.gifImageWithData(pokemon.shinyGifData, 300.0)
	}
	
	fileprivate func setButtonActions()
	{
		doubleButtonsVerticalView.infoButton.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)
		doubleButtonsVerticalView.updateEncountersButton.addTarget(self, action: #selector(updateEncountersPressed), for: .touchUpInside)
	}
	
	fileprivate func resolveEncounterDetails()
	{
		setProbability()
		
		setProbabilityLabelText()
		
		setEncountersLabelText()
		
		minusButton.isEnabled = minusButtonIsEnabled()
	}
	
	fileprivate func setProbability()
	{
		probability = Double(pokemon.encounters) / Double(settingsRepo.shinyOdds!) * 100
	}

	fileprivate func setProbabilityLabelText()
	{
		let huntIsOverOdds = pokemon.encounters > settingsRepo.shinyOdds!
		
		if huntIsOverOdds
		{
			probabilityLabel.text = " Your hunt has gone over odds."
		}
		else
		{
			let formattedProbability = String(format: "%.2f", probability!)
			
			probabilityLabel.text = " Probability is \(formattedProbability)%"
		}
	}
	
	fileprivate func setEncountersLabelText()
	{
		encountersLabel.text = " Encounters: \(pokemon.encounters)"
	}
	
	fileprivate func setNumberLabelText()
	{
		numberLabel.text = " No. \(pokemon.number)"
	}
	
	fileprivate func minusButtonIsEnabled() -> Bool
	{
		return pokemon.encounters != 0
	}
	
	fileprivate func addToHuntButtonIsEnabled() -> Bool
	{
		return resolver.resolveButtonAccess(nameList: currentHuntRepo.currentHuntNames, name: pokemon.name)
	}
	
	
	@IBAction func plusPressed(_ sender: Any)
	{
		pokemon.encounters += 1
		resolveEncounterDetails()
		pokemonRepository.savePokemon(pokemon: pokemon)
	}
	
	@IBAction func minusPressed(_ sender: Any)
	{
		pokemon.encounters -= 1
		resolveEncounterDetails()
		pokemonRepository.savePokemon(pokemon: pokemon)
	}
	
	@IBAction func addToHuntPressed(_ sender: Any)
	{
		currentHuntRepo.addToCurrentHunt(pokemon: pokemon)
		
		addToHuntButton.isEnabled = addToHuntButtonIsEnabled()
		
		popupView.actionLabel.text = "\(pokemon.name) was added to current hunt."
		
		popupHandler.centerPopupView(popupView: popupView)
		
		popupHandler.showPopup(popupView: popupView)
	}
	
	@objc fileprivate func updateEncountersPressed(_ sender: Any)
	{
		setEncountersPressed = true
		performSegue(withIdentifier: "setEncountersSegue", sender: self)
	}
	
	@IBAction func changeCaughtBallPressed(_ sender: Any)
	{
		performSegue(withIdentifier: "shinyTrackerToModalSegue", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if infoPressed
		{
			infoPressed = false
			
			let destVC = segue.destination as! InfoModalVC
			
			destVC.pokemon = pokemon
			destVC.settingsRepo = settingsRepo
		}
		else if setEncountersPressed
		{
			setEncountersPressed = false
			
			let destVC = segue.destination as! SetEncountersModalVC
			
			destVC.pokemon = pokemon
			destVC.pokemonRepository = pokemonRepository
		}
		else
		{
			let destVC = segue.destination as! PokeballModalVC
			
			setPokeballModalProperties(pokeballModalVC: destVC)
		}
	}
	
	fileprivate func setPokeballModalProperties(pokeballModalVC: PokeballModalVC)
	{
		pokeballModalVC.pokemonRepository = pokemonRepository
		pokeballModalVC.pokemon = pokemon
		pokeballModalVC.settingsRepo = settingsRepo
	}
	
	@objc fileprivate func infoButtonPressed(_ sender: Any)
	{
		infoPressed = true
		performSegue(withIdentifier: "infoPopupSegue", sender: self)
	}
	
	@IBAction func cancel(_ unwindSegue: UIStoryboardSegue)
	{}
	
	@IBAction func save(_ unwindSegue: UIStoryboardSegue)
	{
		if let sourceTVC = unwindSegue.source as? PokeballModalVC
		{
			pokemon.caughtBall = sourceTVC.pokemon.caughtBall
			
			pokeballButton.setBackgroundImage(UIImage(named: pokemon.caughtBall), for: .normal)
		}
	}
	
	@IBAction func dismissInfo(_ unwindSegue: UIStoryboardSegue)
	{
		setProbability()
		
		setProbabilityLabelText()
	}
	
	@IBAction func saveEncounters(_ unwindSegue: UIStoryboardSegue)
	{
		let sourceVC = unwindSegue.source as! SetEncountersModalVC
		
		pokemon = sourceVC.pokemon
		
		pokemonRepository.savePokemon(pokemon: pokemon)
		
		setProbability()
		
		setProbabilityLabelText()
		
		setEncountersLabelText()
	}
}
