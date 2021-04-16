//
//  PokedexTVC.swift
//  ShinyDexPrototype
//
//  Created by Sebastian Christiansen on 11/03/2019.
//  Copyright © 2019 Sebastian Christiansen. All rights reserved.
//

import UIKit

class PokedexTVC: UITableViewController, PokemonCellDelegate {
	let searchController = UISearchController(searchResultsController: nil)
	
	var filteredPokemon = [Pokemon]()
	var allPokemon = [Pokemon]()
	var slicedPokemon = [Pokemon]()
	var hunts = [Hunt]()
	let textResolver = TextResolver()
	var selectedIndex = 0
	var generation = 0
	var selectedPokemon: Pokemon?
	var popupHandler = PopupHandler()
	let tableViewHelper = TableViewHelper()
	var pokemonService = PokemonService()
	var fontSettingsService = FontSettingsService()
	var colorService = ColorService()
	var huntService = HuntService()
	
	override func viewDidLoad() {
        super.viewDidLoad()

		allPokemon = pokemonService.getAll()
		hunts = huntService.getAll()
		slicedPokemon = slicePokemonList()

		setUIColors()

		setUpScopeBar()
		
		setUpSearchController()
		
		setUpBackButton()
		
		setFonts()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		setTitle()

		hunts = huntService.getAll()

		tableView.reloadData()
	}
	
	fileprivate func setUIColors() {
		navigationController?.navigationBar.backgroundColor = colorService.getSecondaryColor()

		tableView.separatorColor = colorService.getSecondaryColor()
		tableView.backgroundColor = colorService.getSecondaryColor()
		
		searchController.searchBar.backgroundColor = colorService.getSecondaryColor()
		searchController.searchBar.barTintColor = colorService.getSecondaryColor()
	}
	
	fileprivate func setUpScopeBar() {
		searchController.searchBar.scopeButtonTitles = generation == 9 ? ["Caught"] : ["Shinydex", "Caught", "Not Caught"]
		searchController.searchBar.delegate = self
	}
	
	fileprivate func setUpSearchController() {
		searchController.searchResultsUpdater = self
		
		searchController.obscuresBackgroundDuringPresentation = false
		
		searchController.searchBar.placeholder = "Search"
		
		navigationItem.searchController = searchController
		
		definesPresentationContext = true
	}
	
	fileprivate func setUpBackButton() {
		let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
		
		navigationItem.backBarButtonItem = backButton
		
		navigationController?.navigationBar.tintColor = colorService.getTertiaryColor()
	}
	
	fileprivate func setNavigationBarFont() {
		let navigationBarTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor(),
			NSAttributedString.Key.font: fontSettingsService.getXxLargeFont()
		]
		navigationController?.navigationBar.titleTextAttributes = navigationBarTitleTextAttributes
	}
	
	fileprivate func setFonts() {
		let attributes = [
			NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor(),
			NSAttributedString.Key.font: fontSettingsService.getSmallFont()
		]
		UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
		let searchBarTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField
		searchBarTextField?.textColor = colorService.getTertiaryColor()
		searchBarTextField?.font = fontSettingsService.getSmallFont()
		let searchBarPlaceHolderLabel = searchBarTextField!.value(forKey: "placeholderLabel") as? UILabel
		searchBarPlaceHolderLabel?.font = fontSettingsService.getSmallFont()
		searchController.searchBar.setScopeBarButtonTitleTextAttributes([NSAttributedString.Key.font: fontSettingsService.getXxSmallFont(), NSAttributedString.Key.foregroundColor: colorService.getTertiaryColor()], for: .normal)
	}
	
	fileprivate func setTitle() {
		navigationItem.title = textResolver.getGenTitle(gen: generation)
	}
	
	fileprivate func slicePokemonList() -> [Pokemon] {
		switch generation {
		case 0:
			return Array(allPokemon[0..<151])
		case 1:
			return Array(allPokemon[151..<251])
		case 2:
			return Array(allPokemon[251..<386])
		case 3:
			return Array(allPokemon[386..<493])
		case 4:
			return Array(allPokemon[493..<649])
		case 5:
			return Array(allPokemon[649..<721])
		case 6:
			return Array(allPokemon[721..<807])
		case 7:
			return Array(allPokemon[807..<893])
		default:
			return allPokemon.filter({$0.caughtBall != "none"})
		}
	}

	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		searchController.searchBar.resignFirstResponder()
	}
	
	func changeCaughtButtonPressed(_ sender: UIButton) {
		if let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView) {
			selectedPokemon = getSelectedPokemon(index: indexPath.row)
			
			tableView.reloadRows(at: [indexPath], with: .automatic)
		}
		
		performSegue(withIdentifier: "pickPokeball", sender: self)
	}
	
	func addToHuntPressed(_ sender: UIButton) {
		if let indexPath = tableViewHelper.getPressedButtonIndexPath(sender, tableView) {
			selectedPokemon = getSelectedPokemon(index: indexPath.row)
			if (hunts.isEmpty) {
				huntService.createNewHuntWithPokemon(hunts: &hunts, pokemon: selectedPokemon!)
				popupHandler.showPopup(text: "\(selectedPokemon!.name) was added to New Hunt.")
				tableView.reloadData()
			}
			else if (hunts.count == 1) {
				huntService.addToOnlyExistingHunt(hunts: &hunts, pokemon: selectedPokemon!)
				popupHandler.showPopup(text: "\(selectedPokemon!.name) was added to \(hunts[0].name).")
				tableView.reloadData()
			}
			else {
				performSegue(withIdentifier: "pickHunt", sender: self)
			}
		}
	}
	
	fileprivate func getSelectedPokemon(index: Int) -> Pokemon {
		if (isFiltering()) {
			return filteredPokemon[index]
		}
		else {
			return slicedPokemon[index]
		}
	}
	
	func searchBarIsEmpty() -> Bool {
		return searchController.searchBar.text?.isEmpty ?? true
	}
	
	func filterContentForSearchText(_ searchText: String, scope: String = "Regular") {
		filteredPokemon = slicedPokemon.filter( {(pokemon : Pokemon) -> Bool in
			
			let doesCategoryMatch = (scope == "Shinydex") || (scope == pokemon.caughtDescription)
			
			if (searchBarIsEmpty()) {
				return doesCategoryMatch
			}
			
			return doesCategoryMatch && pokemon.name.lowercased().contains(searchText.lowercased())
		})
		tableView.reloadData()
	}
	
	func isFiltering() -> Bool {
		let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
		return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
	}
	
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return isFiltering() ? filteredPokemon.count : slicedPokemon.count
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 65.0;
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokemonCell", for: indexPath) as! PokemonCell
		cell.cellDelegate = self
		selectedPokemon = getSelectedPokemon(index: indexPath.row)
		setCellImage(pokemonCell: cell, pokemon: selectedPokemon!)
		setPokemonCellProperties(pokemonCell: cell, pokemon: selectedPokemon!)
        return cell
    }
	
	fileprivate func setCellImage(pokemonCell: PokemonCell, pokemon: Pokemon) {
		pokemonCell.sprite.image = UIImage(named: pokemon.name.lowercased())
	}
	
	fileprivate func setPokemonCellProperties(pokemonCell: PokemonCell, pokemon: Pokemon) {
		pokemonCell.pokemonName?.text = pokemon.name
		pokemonCell.pokemonNumber.text = "No. \(String(pokemon.number + 1))"
		pokemonCell.caughtButton.setBackgroundImage(UIImage(named: pokemon.caughtBall), for: .normal)
		pokemonCell.pokemonName.font = fontSettingsService.getSmallFont()
		pokemonCell.pokemonNumber.font = fontSettingsService.getExtraSmallFont()
		pokemonCell.pokemonName.textColor = colorService.getTertiaryColor()
		pokemonCell.pokemonNumber.textColor = colorService.getTertiaryColor()
		pokemonCell.addToCurrentHuntButton.tintColor = colorService.getTertiaryColor()
		setAddToHuntButtonState(pokemonCell: pokemonCell, isBeingHunted: pokemon.isBeingHunted)
	}
	
	fileprivate func setAddToHuntButtonState(pokemonCell: PokemonCell, isBeingHunted: Bool) {
		pokemonCell.addToCurrentHuntButton.isEnabled = !isBeingHunted
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedIndex = indexPath.row
		performSegue(withIdentifier: "trackShiny", sender: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let identifier = segue.identifier
		if (identifier == "pickPokeball") {
			let destVC = segue.destination as? PokeballModalVC
			destVC?.pokemon = selectedPokemon
		}
		else if (segue.identifier == "pickHunt") {
			let destVC = segue.destination as? HuntPickerModalVC
			destVC?.pokemon = selectedPokemon
		}
		else {
			let destVC = segue.destination as? ShinyTrackerVC
			destVC?.pokemon = isFiltering() ? filteredPokemon[selectedIndex] : slicedPokemon[selectedIndex]
		}
	}
	
	@IBAction func save(_ unwindSegue: UIStoryboardSegue) {
		if let sourceTVC = unwindSegue.source as? PokeballModalVC {
			selectedPokemon?.caughtBall = sourceTVC.pokemon.caughtBall
			pokemonService.save(pokemon: selectedPokemon!)
			if (selectedPokemon?.caughtBall == "none") {
				if (isFiltering() && searchController.searchBar.selectedScopeButtonIndex == 1) {
					filteredPokemon.removeAll(where: {$0.name == selectedPokemon?.name})
				}
				if (generation == 9) {
					slicedPokemon.removeAll(where: {$0.name == selectedPokemon?.name})
				}
			}
			tableView.reloadData()
		}
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.backgroundColor = colorService.getPrimaryColor()
	}

	@IBAction func finish(_ unwindSegue: UIStoryboardSegue) {
		tableView.reloadData()
		let source = unwindSegue.source as! HuntPickerModalVC
		let name = source.pickedHuntName!
		popupHandler.showPopup(text: "\(selectedPokemon!.name) was added to \(name).")
	}
}
