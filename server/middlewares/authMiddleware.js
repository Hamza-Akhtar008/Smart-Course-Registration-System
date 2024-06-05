import JWT from "jsonwebtoken"
const userAuth = async (req, res, next) => {
    const authheader = req.headers.authorization;
    if ((!authheader)) {
        next('Auth Failed')
    }
    const token = authheader
    try {
        const Payload = JWT.verify(token, process.env.secret_Key)
        req.body.user = { userId: Payload.userId }

        next()
    } catch (error) {
        next('Auth Failed')
    }
}
export default userAuth