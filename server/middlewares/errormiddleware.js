const errorMiddleware = (error, req, res, next) => {
    console.log(error);
    const defaultErrors = {
        statusCode: 500,
        message: error,
    }

    //Missing field Error
    if (error.name == "ValidationError") {
        defaultErrors.statusCode = 400
        defaultErrors.message = Object.values(error.errors).map(item => item.message).join(",")

    }
    // duplicate Error
    if (error.code && error.code == 11000) {
        defaultErrors.statusCode = 400
        defaultErrors.message = `${Object.keys(error.keyValue)} filed has to be unique`
    }
    res.status(defaultErrors.statusCode).json({ message: defaultErrors.message })
}

export default errorMiddleware;