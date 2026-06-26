import province from "@/data/tinh_tp.json";
export function GET(request) {
  const token = request.headers.get("x-token");
  console.log(`Token: ${token}`);
  const data = Object.values(province);
  data.sort((a, b) => a.code - b.code);
  return Response.json({
    status: "success",
    data,
  });
}
