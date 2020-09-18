//
//  HuntStateService.swift
//  ShinyDex
//
//  Created by Sebastian Christiansen on 24/03/2020.
//  Copyright © 2020 Sebastian Christiansen. All rights reserved.
//

import Foundation

class HuntStateService
{
	fileprivate var oddsService = OddsService()
	fileprivate var huntStateRepository = HuntStateRepository()

	func get() -> HuntState
	{
		let huntState = huntStateRepository.get()
		return huntState
	}

	func save(_ huntState: HuntState)
	{
		huntStateRepository.save(huntState)
	}
}
