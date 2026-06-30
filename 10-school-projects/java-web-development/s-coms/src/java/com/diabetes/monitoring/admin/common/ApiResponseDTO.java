package com.diabetes.monitoring.admin.common;

/**
 * Simple response model for Admin JSON actions.
 */
public class ApiResponseDTO {
    private final boolean success;
    private final String message;

    /**
     * Creates a new ApiResponseDTO instance.
     */
    public ApiResponseDTO(boolean success, String message) {
        this.success = success;
        this.message = message == null ? "" : message;
    }

    /**
     * Handles is success for the Admin module.
     *
     * @return the operation result
     */
    public boolean isSuccess() {
        return success;
    }

    /**
     * Gets message for the Admin module.
     *
     * @return the operation result
     */
    public String getMessage() {
        return message;
    }
}

