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
        // tableView.separatorStyle = .singleLine
        tableView.separatorColor = .clear // 디바이더 제거
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.separatorStyle = .none
        // 중복 방지
        cell.contentView.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }

        // 마지막 셀은 스킵
        guard indexPath.row < routines.count - 1 else { return }

        let divider = UIView()
        divider.tag = 999
        divider.backgroundColor = .white
        divider.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(divider)

        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: 6),
            divider.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])
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
