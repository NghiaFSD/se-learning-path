const { User } = require("../models/index");
class UserRepository extends BaseRepository {
  constructor() {
    this.setModel(User);
  }

  getUsers(limit) {
    this.model.findAll({
      limit,
      order: [["id", "dessc"]],
    });
  }
}

//Service: userRepository.getUsers(10)
