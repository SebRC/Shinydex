//
//  GameSettingsContainer.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 08/05/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import UIKit

class GameSettingsContainer: UIView
{
	var fontSettingsService = FontSettingsService()
	var colorService = ColorService()
	var huntStateService = HuntStateService()
	var oddsService = OddsService()
	var switchStateService = SwitchStateService()
	var huntState: HuntState?
	var gameSettingsCells: [GameSettingsCell]?

	let nibName = "GameSettingsContainer"
    var contentView: UIView?
	@IBOutlet weak var generationLabel: UILabel!
	@IBOutlet weak var generationSegmentedControl: UISegmentedControl!
	@IBOutlet weak var shinyCharmCell: GameSettingsCell!
	@IBOutlet weak var lureCell: GameSettingsCell!
	@IBOutlet weak var masudaCell: GameSettingsCell!
	@IBOutlet weak var pokeradarCell: GameSettingsCell!
	@IBOutlet weak var genTwoBreedingCell: GameSettingsCell!
	@IBOutlet weak var sosChainCell: GameSettingsCell!
	@IBOutlet weak var shinyOddsLabel: UILabel!
	@IBOutlet weak var generationSeparator: UIView!
	@IBOutlet weak var chainFishingCell: GameSettingsCell!
	@IBOutlet weak var dexNavCell: GameSettingsCell!
	@IBOutlet weak var friendSafariCell: GameSettingsCell!
	@IBOutlet weak var explanationLabel: UILabel!
	@IBOutlet weak var explanationSeparator: UIView!


	required init?(coder aDecoder: NSCoder)
	{
        super.init(coder: aDecoder)
        commonInit()

		huntState = huntStateService.get()

		gameSettingsCells = [genTwoBreedingCell, masudaCell, pokeradarCell, shinyCharmCell, chainFishingCell, dexNavCell, friendSafariCell, sosChainCell, lureCell]

		explanationSeparator.layer.cornerRadius = 5
		generationSeparator.layer.cornerRadius = 5
		genTwoBreedingCell.iconImageView.image = UIImage(named: "gyarados")
		genTwoBreedingCell.titleLabel.text = "Gen 2 breeding"
		genTwoBreedingCell.descriptionLabel.text = "Increased shiny odds from breeding shinies are only available in generation 2"
		masudaCell.iconImageView.image = UIImage(named: "egg")
		masudaCell.titleLabel.text = "Masuda"
		masudaCell.descriptionLabel.text = "The Masuda method is only available from generation 4 and onwards"
		pokeradarCell.iconImageView.image = UIImage(named: "poke-radar")
		pokeradarCell.titleLabel.text = "Pokéradar"
		pokeradarCell.descriptionLabel.text = "The Pokéradar is only available in Diamond, Pearl, Platinum, X and Y (Generation 4 & 6)"
		shinyCharmCell.iconImageView.image = UIImage(named: "shiny-charm")
		shinyCharmCell.titleLabel.text = "Shiny Charm"
		shinyCharmCell.descriptionLabel.text = "The shiny charm is only available from generation 5 and onwards"
		chainFishingCell.iconImageView.image = UIImage(named: "super-rod")
		chainFishingCell.titleLabel.text = "Chain fishing"
		chainFishingCell.descriptionLabel.text = "Chain fishing is only available in generation 6 (X, Y, Omega Ruby and Alpha Sapphire)"
		dexNavCell.iconImageView.image = UIImage(named: "wide-lens")
		dexNavCell.titleLabel.text = "DexNav"
		dexNavCell.descriptionLabel.text = "The DexNav is only available in Omega Ruby & Alpha Sapphire (Generation 6)"
		friendSafariCell.iconImageView.image = UIImage(named: "heart-mail")
		friendSafariCell.titleLabel.text = "Friend Safari"
		friendSafariCell.descriptionLabel.text = "The Friend Safari is only available in X & Y (Generation 6)"
		sosChainCell.iconImageView.image = UIImage(named: "sos")
		sosChainCell.titleLabel.text = "SOS chaining"
		sosChainCell.descriptionLabel.text = "SOS chaining is only available in generation 7"
		lureCell.iconImageView.image = UIImage(named: "max-lure")
		lureCell.titleLabel.text = "Lure"
		lureCell.descriptionLabel.text = "Lures are only available in Let's Go Pikachu & Eevee"
		lureCell.actionSwitch.addTarget(self, action: #selector(changeIsLureInUse), for: .valueChanged)
		shinyCharmCell.actionSwitch.addTarget(self, action: #selector(changeIsShinyCharmActive), for: .valueChanged)
		masudaCell.actionSwitch.addTarget(self, action: #selector(changeIsMasudaHunting), for: .valueChanged)
		genTwoBreedingCell.actionSwitch.addTarget(self, action: #selector(changeIsGen2Breeding), for: .valueChanged)
		friendSafariCell.actionSwitch.addTarget(self, action: #selector(changeIsFriendSafariHunting), for: .valueChanged)
		chainFishingCell.actionSwitch.addTarget(self, action: #selector(changeIsChainFishing(_:)), for: .valueChanged)
		sosChainCell.actionSwitch.addTarget(self, action: #selector(changeIsSosChaining), for: .valueChanged)
		generationSegmentedControl.addTarget(self, action: #selector(changeGenerationPressed), for: .valueChanged)
		setUIColors()
		setFonts()
		setShinyOddsLabelText()
		resolveUIObjectsState()
    }

    override init(frame: CGRect)
	{
        super.init(frame: frame)
        commonInit()
    }

    func commonInit()
	{
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
    }

    func loadViewFromNib() -> UIView?
	{
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

	fileprivate func resolveUIObjectsState()
	{
		generationSegmentedControl.selectedSegmentIndex = huntState!.generation

		genTwoBreedingCell.actionSwitch.isOn = huntState!.huntMethod == .Gen2Breeding
		masudaCell.actionSwitch.isOn = huntState!.huntMethod == .Masuda
		shinyCharmCell.actionSwitch.isOn = huntState!.isShinyCharmActive
		friendSafariCell.actionSwitch.isOn = huntState!.huntMethod == .FriendSafari
		chainFishingCell.actionSwitch.isOn = huntState!.huntMethod == .ChainFishing
		sosChainCell.actionSwitch.isOn = huntState!.huntMethod == .SosChaining
		lureCell.actionSwitch.isOn = huntState!.huntMethod == .Lure

		setAllImageViewAlphas()
		resolveSwitchStates()
	}

	fileprivate func setShinyOddsLabelText()
	{
		shinyOddsLabel.text = "Shiny Odds: 1/\(huntState!.shinyOdds)"
	}

	fileprivate func setImageViewAlpha(imageView: UIImageView, isSwitchOn: Bool)
	{
		imageView.alpha = isSwitchOn ? 1.0 : 0.5
	}

	func setUIColors()
	{
		contentView?.backgroundColor = colorService.getSecondaryColor()
		explanationLabel.textColor = colorService.getTertiaryColor()
		explanationSeparator.backgroundColor = colorService.getPrimaryColor()
		generationSeparator.backgroundColor = colorService.getPrimaryColor()
		generationLabel.textColor = colorService.getTertiaryColor()
		shinyOddsLabel.textColor = colorService.getTertiaryColor()
		let segmentedControlTitleTextAttributes = [NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor()]
		generationSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .selected)
		generationSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .normal)
		generationLabel.textColor = colorService.getTertiaryColor()
		generationSegmentedControl.backgroundColor = colorService.getSecondaryColor()
		generationSegmentedControl.tintColor = colorService.getPrimaryColor()
	}

	func setCellColors()
	{
		for cell in gameSettingsCells!
		{
			cell.setUIColors()
		}
	}

	func setFonts()
	{
		explanationLabel.font = fontSettingsService.getSmallFont()
		generationLabel.font = fontSettingsService.getExtraLargeFont()
		shinyOddsLabel.font = fontSettingsService.getMediumFont()
		generationSegmentedControl.setTitleTextAttributes(fontSettingsService.getFontAsNSAttibutedStringKey( fontSize: fontSettingsService.getExtraSmallFont().pointSize) as? [NSAttributedString.Key : Any], for: .normal)
	}

	func setCellFonts()
	{
		for cell in gameSettingsCells!
		{
			cell.setFonts()
		}
	}

	@objc fileprivate func changeIsGen2Breeding(_ sender: Any)
	{
		huntState!.huntMethod = genTwoBreedingCell.actionSwitch.isOn ? .Gen2Breeding : .Encounters
		setImageViewAlpha(imageView: genTwoBreedingCell.iconImageView, isSwitchOn: huntState!.huntMethod == .Gen2Breeding)
		huntStateService.save(huntState!)
		huntState?.shinyOdds = oddsService.getShinyOdds(generation: generationSegmentedControl.selectedSegmentIndex, isCharmActive: shinyCharmCell.actionSwitch.isOn, huntMethod: huntState!.huntMethod)
		setShinyOddsLabelText()
	}

	@objc fileprivate func changeIsFriendSafariHunting()
	{
		huntState!.huntMethod = friendSafariCell.actionSwitch.isOn ? .FriendSafari : .Encounters
		setImageViewAlpha(imageView: friendSafariCell.iconImageView, isSwitchOn: huntState!.huntMethod == .FriendSafari)
		turnSwitchesOff(enabledCell: friendSafariCell, huntMethod: huntState!.huntMethod)
	}

	@objc fileprivate func changeIsLureInUse(_ sender: Any)
	{
		huntState!.huntMethod = lureCell.actionSwitch.isOn ? .Lure : .Encounters
		setImageViewAlpha(imageView: lureCell.iconImageView, isSwitchOn: huntState!.huntMethod == .Lure)
		huntStateService.save(huntState!)
		huntState?.shinyOdds = oddsService.getShinyOdds(generation: generationSegmentedControl.selectedSegmentIndex, isCharmActive: shinyCharmCell.actionSwitch.isOn, huntMethod: huntState!.huntMethod)
		setShinyOddsLabelText()
	}

	@objc fileprivate func changeIsShinyCharmActive(_ sender: Any)
	{
		huntState?.isShinyCharmActive = shinyCharmCell.actionSwitch.isOn
		setImageViewAlpha(imageView: shinyCharmCell.iconImageView, isSwitchOn: huntState!.isShinyCharmActive)
		huntStateService.save(huntState!)
		huntState?.shinyOdds = oddsService.getShinyOdds(generation: generationSegmentedControl.selectedSegmentIndex, isCharmActive: huntState!.isShinyCharmActive, huntMethod: huntState!.huntMethod)
		setShinyOddsLabelText()
	}

	@objc fileprivate func changeIsMasudaHunting(_ sender: Any)
	{
		huntState?.huntMethod = masudaCell.actionSwitch.isOn ? .Masuda : .Encounters
		setImageViewAlpha(imageView: masudaCell.iconImageView, isSwitchOn: huntState!.huntMethod == .Masuda)
		turnSwitchesOff(enabledCell: masudaCell, huntMethod: huntState!.huntMethod)
	}

	@objc fileprivate func changeIsChainFishing(_ sender: Any)
	{
		huntState?.huntMethod = chainFishingCell.actionSwitch.isOn ? .ChainFishing : .Encounters
		setImageViewAlpha(imageView: chainFishingCell.iconImageView, isSwitchOn: huntState!.huntMethod == .ChainFishing)
		turnSwitchesOff(enabledCell: chainFishingCell, huntMethod: huntState!.huntMethod)
	}

	@objc fileprivate func changeIsSosChaining(_ sender: Any)
	{
		huntState?.huntMethod = sosChainCell.actionSwitch.isOn ? .SosChaining : .Encounters
		setImageViewAlpha(imageView: sosChainCell.iconImageView, isSwitchOn: huntState!.huntMethod == .SosChaining)
		turnSwitchesOff(enabledCell: sosChainCell, huntMethod: huntState!.huntMethod)
	}

	@objc fileprivate func changeGenerationPressed(_ sender: Any)
	{
		huntState!.generation = generationSegmentedControl.selectedSegmentIndex

		if huntState?.huntMethod != .Masuda || huntState?.generation == 0 || huntState?.generation == 6
		{
			huntState?.huntMethod = .Encounters
		}

		resolveSwitchStates()

		setAllImageViewAlphas()

		huntState!.shinyOdds = oddsService.getShinyOdds(generation: huntState!.generation, isCharmActive: huntState!.isShinyCharmActive, huntMethod: huntState!.huntMethod)

		setShinyOddsLabelText()

		huntStateService.save(huntState!)
	}

	fileprivate func setAllImageViewAlphas()
	{
		setImageViewAlpha(imageView: shinyCharmCell.iconImageView, isSwitchOn: huntState!.isShinyCharmActive)
		if huntState?.generation == 0
		{
			setImageViewAlpha(imageView: genTwoBreedingCell.iconImageView, isSwitchOn: huntState!.huntMethod == .Gen2Breeding)
		}
		else
		{
			setImageViewAlpha(imageView: genTwoBreedingCell.iconImageView, isSwitchOn: false)
		}
		if huntState?.generation == 6
		{
			setImageViewAlpha(imageView: lureCell.iconImageView, isSwitchOn: huntState!.huntMethod == .Lure)
		}
		else
		{
			setImageViewAlpha(imageView: lureCell.iconImageView, isSwitchOn: false)
		}
		setImageViewAlpha(imageView: masudaCell.iconImageView, isSwitchOn: huntState!.huntMethod == .Masuda)
		setImageViewAlpha(imageView: pokeradarCell.iconImageView, isSwitchOn: huntState!.huntMethod == .Pokeradar)
		setImageViewAlpha(imageView: chainFishingCell.iconImageView, isSwitchOn: huntState!.huntMethod == .ChainFishing)
		setImageViewAlpha(imageView: dexNavCell.iconImageView, isSwitchOn: huntState!.huntMethod == .DexNav)
		setImageViewAlpha(imageView: friendSafariCell.iconImageView, isSwitchOn: huntState!.huntMethod == .FriendSafari)
		setImageViewAlpha(imageView: sosChainCell.iconImageView, isSwitchOn: huntState!.huntMethod == .SosChaining)
	}

	fileprivate func turnSwitchesOff(enabledCell: GameSettingsCell, huntMethod: HuntMethod)
	{
		gameSettingsCells!.removeAll{$0 == enabledCell || $0 == shinyCharmCell}
		for cell in gameSettingsCells!
		{
			setImageViewAlpha(imageView: cell.iconImageView, isSwitchOn: false)
			cell.actionSwitch.isOn = false
		}
		setImageViewAlpha(imageView: shinyCharmCell.iconImageView, isSwitchOn: huntState!.isShinyCharmActive)
		setImageViewAlpha(imageView: enabledCell.iconImageView, isSwitchOn: enabledCell.actionSwitch.isOn)
		gameSettingsCells!.append(enabledCell)
		gameSettingsCells!.append(shinyCharmCell)
		huntStateService.save(huntState!)
		huntState?.shinyOdds = oddsService.getShinyOdds(generation: generationSegmentedControl.selectedSegmentIndex, isCharmActive: shinyCharmCell.actionSwitch.isOn, huntMethod: huntState!.huntMethod)
			setShinyOddsLabelText()
	}

	fileprivate func resolveSwitchStates()
	{
		switchStateService.resolveShinyCharmSwitchState(huntState: huntState!, shinyCharmSwitch: shinyCharmCell.actionSwitch)
		switchStateService.resolveLureSwitchState(huntState: huntState!, lureSwitch: lureCell.actionSwitch)
		switchStateService.resolveMasudaSwitchState(huntState: huntState!, masudaSwitch: masudaCell.actionSwitch)
		switchStateService.resolveGen2BreddingSwitchState(huntState: huntState!, gen2BreedingSwitch: genTwoBreedingCell.actionSwitch)
		switchStateService.resolveFriendSafariSwitchState(huntState: huntState!, friendSafariSwitch: friendSafariCell.actionSwitch)
		switchStateService.resolveSosChainingSwitchState(huntState: huntState!, sosChainingSwitch: sosChainCell.actionSwitch)
		switchStateService.resolveChainFishingSwitchState(huntState: huntState!, chainFishingSwitch: chainFishingCell.actionSwitch)
	}
}
