//
//  InfoModalVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 05/12/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class InfoModalVC: UIViewController
{
	@IBOutlet weak var infoPopupView: InfoPopupView!
	
	var pokemon: Pokemon!
	var probability: Double?
	var settingsRepository: SettingsRepository!
	var switchStateService = SwitchStateService()
	let oddsService = OddsService()
	let probabilityService = ProbabilityService()
	var shinyOdds: Int?
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		setClearBackground()
		
		roundViewCorner()
		
		setShinyOdds()
		
		resolveSwitchStates()
		
		setButtonActions()
		
		setSwitchActions()
		
		setGenerationSegmentedControlAction()
		
		setInfo()
    }
	
	fileprivate func setClearBackground()
	{
		view.backgroundColor = .clear
	}
	
	fileprivate func roundViewCorner()
	{
		infoPopupView.layer.cornerRadius = 10
	}
	
	fileprivate func setShinyOdds()
	{
		shinyOdds = settingsRepository.shinyOdds
	}
	
	fileprivate func resolveSwitchStates()
	{
		let generation = infoPopupView.generationSegmentedControl.selectedSegmentIndex

		switchStateService.resolveShinyCharmSwitchState(generation: generation, shinyCharmSwitch: infoPopupView.shinyCharmSwitch)
		switchStateService.resolveLureSwitchState(generation: generation, lureSwitch: infoPopupView.lureSwitch)
	}
	
	fileprivate func setButtonActions()
	{
		infoPopupView.cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
		infoPopupView.saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
	}
	
	@objc fileprivate func cancelPressed()
	{
		dismiss(animated: true)
	}
	
	@objc fileprivate func savePressed()
	{
		settingsRepository?.isShinyCharmActive = infoPopupView.shinyCharmSwitch.isOn

		settingsRepository?.isLureInUse = infoPopupView.lureSwitch.isOn
		
		settingsRepository?.generation = infoPopupView.generationSegmentedControl.selectedSegmentIndex
		
		settingsRepository.setShinyOdds()
		
		settingsRepository?.saveSettings()
		
		performSegue(withIdentifier: "infoUnwind", sender: self)
	}
	
	fileprivate func setSwitchActions()
	{
		infoPopupView.shinyCharmSwitch.addTarget(self, action: #selector(switchPressed), for: .touchUpInside)
		infoPopupView.lureSwitch.addTarget(self, action: #selector(switchPressed), for: .touchUpInside)
	}
	
	@objc func switchPressed(sender: UISwitch!)
	{
		setProbability()
		
		setProbabilityLabelText()
		
		setShinyOddsLabelText()
	}
	
	fileprivate func setProbability()
	{
		let generation = infoPopupView.generationSegmentedControl.selectedSegmentIndex
		let isShinyCharmActive = infoPopupView.shinyCharmSwitch.isOn
		let isLureInUse = infoPopupView.lureSwitch.isOn
		let encounters = pokemon.encounters

		shinyOdds = oddsService.getShinyOdds(currentGen: generation, isCharmActive: isShinyCharmActive, isLureInUse: isLureInUse, encounters: encounters)
		probability = probabilityService.getProbability(generation: generation, isCharmActive: isShinyCharmActive, encounters: encounters, shinyOdds: shinyOdds!, isLureInUse: isLureInUse)
	}
	
	fileprivate func setProbabilityLabelText()
	{
		let probabilityLabelText = probabilityService.getProbabilityText(encounters: pokemon.encounters, shinyOdds: shinyOdds!, probability: probability!)

		infoPopupView.probabilityLabel.text = probabilityLabelText
	}
	
	fileprivate func setShinyOddsLabelText()
	{
		infoPopupView.shinyOddsLabel.text = " 1/\(shinyOdds!)"
	}
	
	fileprivate func setGenerationSegmentedControlAction()
	{
		infoPopupView.generationSegmentedControl.addTarget(self, action: #selector(generationChanged), for: .valueChanged)
	}
	
	@objc func generationChanged(sender: UISegmentedControl!)
	{
		let generation = infoPopupView.generationSegmentedControl.selectedSegmentIndex
		
		switchStateService.resolveShinyCharmSwitchState(generation: generation, shinyCharmSwitch: infoPopupView.shinyCharmSwitch)

		switchStateService.resolveLureSwitchState(generation: generation, lureSwitch: infoPopupView.lureSwitch)
		
		setProbability()
		
		setProbabilityLabelText()
		
		setShinyOddsLabelText()

		setEncountersTitleLabelText()
	}

	fileprivate func setEncountersTitleLabelText()
	{
		let generation = infoPopupView.generationSegmentedControl.selectedSegmentIndex

		if generation == 4
		{
			infoPopupView.encountersTitleLabel.text = " Catch Combo"
		}
		else
		{
			infoPopupView.encountersTitleLabel.text = " Encounters"
		}
	}
	
	fileprivate func setInfo()
	{
		setProbability()
		
		setProbabilityLabelText()
		
		setLabelTexts()
		
		setImages()
	}
	
	fileprivate func setLabelTexts()
	{
		infoPopupView.nameLabel.text = " \(pokemon.name)"

		infoPopupView.numberLabel.text = " No. \(pokemon.number + 1)"

		setEncountersTitleLabelText()
		
		infoPopupView.encountersLabel.text = " \(pokemon.encounters)"

		setShinyOddsLabelText()
	}
	
	fileprivate func setImages()
	{
		infoPopupView.spriteImageView.image = pokemon.shinyImage
		infoPopupView.pokeballImageView.image = UIImage(named: pokemon.caughtBall)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		dismissModalOnTouchOutside(touches: touches)
	}
}
