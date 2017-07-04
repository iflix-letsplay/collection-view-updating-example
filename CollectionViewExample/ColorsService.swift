import UIKit

class ColorService {

    let initialColors: [UIColor] = [
        UIColor.red,
        UIColor.green,
        UIColor.blue
    ]

    func shuffle(_ colors: [UIColor]) -> [UIColor]{
        return colors.shuffled()
    }

    func removeOne(from colors: [UIColor]) -> [UIColor] {
        guard colors.count > 0 else { return [] }

        var newColors = colors
        guard let index = newColors.index(of: newColors.shuffled()[0]) else { fatalError() }
        newColors.remove(at: index)

        return newColors
    }

    func replaceOneAndAddOne(to colors: [UIColor]) -> [UIColor] {
        let addableColors = ColorService.availableColors.filter { !colors.contains($0) }.shuffled()

        // For the moment always replace the first and add one at the bottom
        let newTop = addableColors[0]
        let newBottom = addableColors[1]

        let colorsToKeep = colors[1...initialColors.count - 1]

        return [newTop] + colorsToKeep + [newBottom]
    }

    private static let availableColors = [
        UIColor.red,
        UIColor.green,
        UIColor.blue,
        UIColor.yellow,
        UIColor.purple,
        UIColor.brown
    ]
}
