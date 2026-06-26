class BaseRepository {
  model;
  setModel = (model) => {
    this.model = model;
  };
  create = () => {
    //this.#model.create()
  };
  update = () => {};
  destroy = () => {};
  findAll = () => {};
  findOne = () => {};
}
