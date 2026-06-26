# Tư duy xây dựng API đăng nhập với mạng xã hội

1. Khi client call: /auth/login/google

Em sẽ xử lý để trả về redirect url => Url này sẽ trả về client

2. Client sẽ code để tự động chuyển hướng redirect url này

Sau khi chuyển hướng xong => nó sẽ tự redirect về url callback.

Tuy nhiên url callback em phải để ở client (Hiện a đang thấy url callback em để url của server)

3. Tại url callback ở client: Em yêu cầu call api tới callback của server

Vì khi redirect từ google về callback của url sẽ lấy đc code, scope,... => Ném hết query này lên callback server là đc

https://api.congdong.unicode.vn/auth/google/callback?code=4%2F0AVHEtk5NSRVMWxXrXvlXJPhIxucc_omMdWjiwYLYvZRdtThOj_-4_by8BqdyPKlZ6IIYfQ&scope=email+profile+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+openid&authuser=0&prompt=none

4. Phần tiếp theo em tự xử lý để login và trả về accessToken (Cái này em làm rồi)
