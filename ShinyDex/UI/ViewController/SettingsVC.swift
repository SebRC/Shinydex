import UIKit

class SettingsVC: UIViewController, SegueActivated {
	var fontSettingsService = FontSettingsService()
	var colorService = ColorService()
	var popupHandler = PopupHandler()
	var theme = Theme.Primary
	var pokemon: Pokemon!

	@IBOutlet weak var fontSegmentedControl: UISegmentedControl!
	@IBOutlet weak var themeLabel: UILabel!
	@IBOutlet weak var fontLabel: UILabel!
	@IBOutlet weak var primaryEditButton: ButtonIconRight!
	@IBOutlet weak var secondaryEditButton: ButtonIconRight!
	@IBOutlet weak var tertiaryEditButton: ButtonIconRight!
	@IBOutlet weak var themeFontSeparator: UIView!
	@IBOutlet weak var themeSettingsBackgroundView: UIView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var gameSettingsContainer: GameSettingsContainer!

	override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: themeSettingsBackgroundView.topAnchor, constant: 8.0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: gameSettingsContainer.bottomAnchor, constant: -8.0).isActive = true

		gameSettingsContainer.pokemon = pokemon
		gameSettingsContainer.setShinyOddsLabelText()
		gameSettingsContainer.resolveUIObjectsState()
		gameSettingsContainer.setExplanationLabelText()
		gameSettingsContainer.delegate = self
        gameSettingsContainer.gameButton.addTarget(self, action: #selector(gameButtonPressed), for: .touchUpInside)
        gameSettingsContainer.gameButton.setImage(UIImage(named: GamesList.games[Games.Red]!.coverPokemon), for: .normal)
        gameSettingsContainer.gameTitle.text = pokemon.game.rawValue


		setUIColors()
		setFonts()
		roundCorners()
		setFontSettingsControlSelectedSegmentIndex()
		setEditButtonActions()
		setEditButtonTexts()
    }
	
	fileprivate func setUIColors() {
		let navigationBarTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor(),
			NSAttributedString.Key.font: fontSettingsService.getLargeFont()
		]
		
		navigationController?.navigationBar.barTintColor = colorService.getPrimaryColor()
		navigationController?.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes
		navigationController?.navigationBar.tintColor = colorService.getTertiaryColor()
		
		view.backgroundColor = colorService.getSecondaryColor()
		
		themeLabel.textColor = colorService.getTertiaryColor()
		
		primaryEditButton.contentView?.backgroundColor = colorService.getPrimaryColor()
		
		secondaryEditButton.contentView?.backgroundColor = colorService.getSecondaryColor()
		
		tertiaryEditButton.contentView?.backgroundColor = colorService.getTertiaryColor()
		
		let segmentedControlTitleTextAttributes = [NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor()]
		
		fontLabel.textColor = colorService.getTertiaryColor()
		fontSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .selected)
		fontSegmentedControl.setTitleTextAttributes(segmentedControlTitleTextAttributes, for: .normal)
		fontSegmentedControl.backgroundColor = colorService.getPrimaryColor()
		fontSegmentedControl.tintColor = colorService.getSecondaryColor()
		themeFontSeparator.backgroundColor = colorService.getSecondaryColor()
		themeSettingsBackgroundView.backgroundColor = colorService.getPrimaryColor()
	}
	
	fileprivate func setFonts() {
		setAttributedFonts()
		themeLabel.font = fontSettingsService.getExtraLargeFont()
		fontLabel.font = fontSettingsService.getExtraLargeFont()
		primaryEditButton.setFont()
		secondaryEditButton.setFont()
		tertiaryEditButton.setFont()
		gameSettingsContainer.setFonts()
		gameSettingsContainer.setCellFonts()
	}
	
	fileprivate func setAttributedFonts() {
		let navigationBarTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor(),
			NSAttributedString.Key.font: fontSettingsService.getLargeFont()
		]
		navigationController?.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes
		fontSegmentedControl.setTitleTextAttributes(fontSettingsService.getFontAsNSAttibutedStringKey(fontSize: fontSettingsService.getExtraSmallFont().pointSize) as? [NSAttributedString.Key : Any], for: .normal)
	}
	
	fileprivate func roundCorners() {
		gameSettingsContainer.layer.cornerRadius = CornerRadius.standard
		themeSettingsBackgroundView.layer.cornerRadius = CornerRadius.standard
		themeFontSeparator.layer.cornerRadius = CornerRadius.standard
	}
	
	fileprivate func setEditButtonActions() {
		primaryEditButton.button.addTarget(self, action: #selector(primaryEditButtonPressed), for: .touchUpInside)
		secondaryEditButton.button.addTarget(self, action: #selector(secondaryEditButtonPressed), for: .touchUpInside)
		tertiaryEditButton.button.addTarget(self, action: #selector(tertiaryEditButtonPressed), for: .touchUpInside)
	}
	
	fileprivate func setEditButtonTexts() {
		primaryEditButton.label.text = "Primary"
		secondaryEditButton.label.text = "Secondary"
		tertiaryEditButton.label.text = "Tertiary"
	}
	
	fileprivate func setFontSettingsControlSelectedSegmentIndex() {
		if (fontSettingsService.getFontThemeName() == FontThemeName.Modern.description) {
			fontSegmentedControl.selectedSegmentIndex = 0
		}
		else {
			fontSegmentedControl.selectedSegmentIndex = 1
		}
	}
	
	@IBAction func changeFontPressed(_ sender: Any) {
		let fontThemeName = fontSegmentedControl.selectedSegmentIndex == 0 ? FontThemeName.Modern.description : FontThemeName.Retro.description
		fontSettingsService.save(fontThemeName: fontThemeName)
		setFonts()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == "applyToAll") {
			let destVC = segue.destination as! ApplyToAllVC
			destVC.pokemon = pokemon
			destVC.isFromSettings = true
		}
        else if (segue.identifier == "toGameSelector") {
            let destVC = segue.destination as! GameSelectorTVC
            destVC.pokemon = pokemon
            destVC.selectedGame = GamesList.games[pokemon.game]
        }
		else {
			let destVC = segue.destination as! ColorPickerVC

			if (theme == .Tertiary) {
				destVC.currentColor = colorService.getTertiaryHex()
			}
			else if (theme == .Primary) {
				destVC.currentColor = colorService.getPrimaryHex()
			}
			else {
				destVC.currentColor = colorService.getSecondaryHex()
			}
			destVC.theme = theme
		}
	}
	
	@objc fileprivate func primaryEditButtonPressed() {
		theme = .Primary
		performSegue(withIdentifier: "pickColor", sender: self)
	}
	
	@objc fileprivate func secondaryEditButtonPressed() {
		theme = .Secondary
		performSegue(withIdentifier: "pickColor", sender: self)
	}
	
	@objc fileprivate func tertiaryEditButtonPressed() {
		theme = .Tertiary
		performSegue(withIdentifier: "pickColor", sender: self)
	}
    
    @objc fileprivate func gameButtonPressed() {
        performSegue(withIdentifier: "toGameSelector", sender: self)
    }
	
	@IBAction func confirm(_ unwindSegue: UIStoryboardSegue) {
		setUIColors()
		gameSettingsContainer.setUIColors()
		gameSettingsContainer.setCellColors()
		setFonts()
	}

	func segueActivated() {
		performSegue(withIdentifier: "applyToAll", sender: self)
	}
	@IBAction func showSettingsConfirmation(_ unwindSegue: UIStoryboardSegue) {
		popupHandler.showPopup(text: "Game Settings have been applied to all Pokémon.")
	}
    
    @IBAction func gameSelected(_ unwindSegue: UIStoryboardSegue) {
        let source = unwindSegue.source as! GameSelectorTVC
        let selectedGame = source.selectedGame!
        let shouldMethodBeReset = !selectedGame.availableMethods.contains(pokemon.huntMethod)
        pokemon.huntMethod = shouldMethodBeReset ? .Encounters : pokemon.huntMethod
        let shouldShinyCharmBeEnabled = selectedGame.isShinyCharmAvailable
        pokemon.isShinyCharmActive = shouldShinyCharmBeEnabled ? pokemon.isShinyCharmActive : false
        pokemon = source.pokemon
        gameSettingsContainer.pokemon = pokemon
        gameSettingsContainer.gameButton.setImage(UIImage(named: selectedGame.coverPokemon), for: .normal)
        gameSettingsContainer.gameTitle.text = pokemon.game.rawValue
        gameSettingsContainer.resolveUIObjectsState()
    }
}
