import UIKit

class RoutineListViewController: UITableViewController {

    var routines: [Routine] = []
    var onLongPress: ((Routine) -> Void)?
    var onEdit: ((Routine) -> Void)?
    var onDelete: ((Routine) -> Void)?
    var onComplete: ((Routine) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(RoutineCell.self, forCellReuseIdentifier: "RoutineCell")
        tableView.rowHeight = 54
        tableView.separatorStyle = .singleLine
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        routines.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let routine = routines[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineCell", for: indexPath) as? RoutineCell else {
            return UITableViewCell()
        }

        cell.configure(with: routine)
        cell.onLongPress = { [weak self] in self?.onLongPress?(routine) }
        cell.onEdit = { [weak self] in self?.onEdit?(routine) }
        cell.onDelete = { [weak self] in self?.onDelete?(routine) }
        cell.onComplete = { [weak self] in self?.onComplete?(routine) }

        return cell
    }

    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let routine = routines[indexPath.row]
        
        let edit = UIContextualAction(style: .normal, title: "수정") { [weak self] _, _, _ in
            self?.onEdit?(routine)
        }
        edit.backgroundColor = UIColor(named: "MediumGray")

        let delete = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, _ in
            self?.onDelete?(routine)
        }
        delete.backgroundColor = UIColor(named: "Red")

        let complete = UIContextualAction(style: .normal, title: "완료") { [weak self] _, _, _ in
            self?.onComplete?(routine)
        }
        complete.backgroundColor = UIColor(named: "Primary")

        return UISwipeActionsConfiguration(actions: [complete, delete, edit])
    }
}
