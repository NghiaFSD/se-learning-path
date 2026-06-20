const Transformer = require("../core/Transformer");

class UserTransformer extends Transformer {
  response(instance) {
    return {
      UID: instance.id,
      fullName: instance.fullname,
      email: instance.email,
      status: instance.status,
      statusText: instance.status === true ? "Kích hoạt" : "Chưa kích hoạt",
      providerId: instance.provider_id,
      createdAt: instance.created_at,
      updatedAt: instance.updated_at,
    };
  }
}
module.exports = UserTransformer;
