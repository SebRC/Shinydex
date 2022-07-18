import UIKit

@IBDesignable
class ButtonStrip: UIView {
	@IBOutlet weak var methodMapSeparator: UIView!
	@IBOutlet weak var updateEncountersButton: UIButton!
	@IBOutlet weak var methodButton: UIButton!
	@IBOutlet weak var encountersIncrementSeparator: UIView!
	@IBOutlet weak var pokeballButton: UIButton!
	@IBOutlet weak var mapBallSeparator: UIView!
	@IBOutlet weak var locationButton: UIButton!
	@IBOutlet weak var ballOddsSeparator: UIView!
	@IBOutlet weak var oddsLabel: UILabel!
	@IBOutlet weak var incrementButton: UIButton!
	@IBOutlet weak var incrementMethodSeparator: UIView!

	fileprivate var colorService = ColorService()
	fileprivate var fontSettingsService = FontSettingsService()
	
	let nibName = "ButtonStrip"
    var contentView:UIView?
	
	required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initContentView(nibName: nibName, contentView: &contentView)

		setColors()
		roundCorners()
		oddsLabel.font = fontSettingsService.getSmallFont()
    }
	
    override init(frame: CGRect) {
        super.init(frame: frame)
        initContentView(nibName: nibName, contentView: &contentView)
    }
	
	fileprivate func setColors() {
		contentView?.backgroundColor = colorService.getPrimaryColor()
		
		encountersIncrementSeparator.backgroundColor = colorService.getSecondaryColor()
		incrementMethodSeparator.backgroundColor = colorService.getSecondaryColor()
		methodMapSeparator.backgroundColor = colorService.getSecondaryColor()
		mapBallSeparator.backgroundColor = colorService.getSecondaryColor()
		ballOddsSeparator.backgroundColor = colorService.getSecondaryColor()
		updateEncountersButton.tintColor = colorService.getTertiaryColor()
		incrementButton.tintColor = colorService.getTertiaryColor()
		methodButton.tintColor = colorService.getTertiaryColor()
		oddsLabel.textColor = colorService.getTertiaryColor()
	}
	
	fileprivate func roundCorners() {
		encountersIncrementSeparator.layer.cornerRadius = CornerRadius.standard
		incrementMethodSeparator.layer.cornerRadius = CornerRadius.standard
		methodMapSeparator.layer.cornerRadius = CornerRadius.standard
		mapBallSeparator.layer.cornerRadius = CornerRadius.standard
		ballOddsSeparator.layer.cornerRadius = CornerRadius.standard
		layer.cornerRadius = CornerRadius.standard
	}
}
