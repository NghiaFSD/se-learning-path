<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>AI Chat - DiabetesCare</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #2dbbbc;
            --primary-dark: #239495;
            --primary-light: #e8f7f4;
            --sidebar-width: 280px;
            --sidebar-collapsed: 80px;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: #f8fafc;
            overflow-x: hidden;
        }

        /* Sidebar - Same as dashboard */
        .sidebar-modern {
            position: fixed;
            left: 0;
            top: 0;
            width: var(--sidebar-width);
            height: 100vh;
            background: white;
            border-right: 1px solid #e2e8f0;
            z-index: 1000;
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
        }

        .sidebar-header {
            padding: 1.5rem;
            border-bottom: 1px solid #e2e8f0;
        }

        .brand-dashboard {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            text-decoration: none;
            color: var(--primary-color);
            font-weight: 700;
            font-size: 1.25rem;
        }

        .brand-icon-dash {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }

        .user-profile {
            padding: 1.5rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            border-bottom: 1px solid #e2e8f0;
        }

        .user-avatar {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 1.25rem;
        }

        .user-info h6 {
            margin: 0;
            font-weight: 600;
            color: #1e293b;
        }

        .user-info small {
            color: #64748b;
        }

        .sidebar-nav {
            flex: 1;
            padding: 1rem 0;
            overflow-y: auto;
        }

        .nav-item-dash {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 0.875rem 1.5rem;
            color: #64748b;
            text-decoration: none;
            transition: all 0.2s ease;
            border-left: 3px solid transparent;
        }

        .nav-item-dash:hover,
        .nav-item-dash.active {
            background: rgba(45, 187, 188, 0.08);
            color: var(--primary-color);
            border-left-color: var(--primary-color);
        }

        .nav-item-dash i {
            font-size: 1.25rem;
            width: 24px;
        }

        .sidebar-footer {
            padding: 1rem 1.5rem;
            border-top: 1px solid #e2e8f0;
        }

        .btn-logout {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            width: 100%;
            padding: 0.75rem 1rem;
            border: none;
            background: #f1f5f9;
            color: #64748b;
            border-radius: 10px;
            font-weight: 500;
            transition: all 0.2s ease;
            text-decoration: none;
        }

        .btn-logout:hover {
            background: #fee2e2;
            color: #ef4444;
        }

        /* Main Content */
        .main-content-dash {
            margin-left: var(--sidebar-width);
            min-height: 100vh;
            padding: 2rem;
        }

        /* Header */
        .dash-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 2rem;
        }

        .welcome-section h1 {
            font-size: 1.875rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 0.5rem;
        }

        .welcome-section h1 span {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .welcome-section p {
            color: #64748b;
            margin: 0;
        }

        .status-badge-ai {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            background: rgba(16, 185, 129, 0.1);
            color: #10b981;
            border-radius: 20px;
            font-size: 0.875rem;
            font-weight: 600;
        }

        .status-badge-ai::before {
            content: '';
            width: 8px;
            height: 8px;
            background: #10b981;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        /* Chat Layout */
        .chat-layout {
            display: grid;
            grid-template-columns: 1fr 350px;
            gap: 1.5rem;
            height: calc(100vh - 200px);
        }

        /* Chat Container */
        .chat-container {
            background: white;
            border-radius: 20px;
            border: 1px solid #e2e8f0;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.05);
        }

        .chat-header {
            padding: 1rem 1.5rem;
            background: white;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .ai-avatar {
            width: 40px;
            height: 40px;
            background: #f1f5f9;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #2dbbbc;
            font-size: 1.25rem;
            border: 1px solid #e2e8f0;
        }

        .ai-info h5 {
            margin: 0;
            font-weight: 600;
            color: #1e293b;
            font-size: 1rem;
        }

        .ai-info p {
            margin: 0;
            font-size: 0.8rem;
            color: #64748b;
        }

        .chat-messages {
            flex: 1;
            overflow-y: auto;
            padding: 1.5rem;
            background: white; /* Nền trắng như yêu cầu */
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .message {
            display: flex;
            width: 100%;
            animation: fadeInUp 0.2s ease;
            margin-bottom: 2px;
        }

        .message.incoming {
            justify-content: flex-start;
        }

        .message.outgoing {
            justify-content: flex-end;
        }

        .message-avatar {
            display: none;
        }

        .message-content {
            max-width: 80%;
        }

        .message-bubble {
            padding: 0.6rem 1rem;
            border-radius: 18px;
            font-size: 0.95rem;
            line-height: 1.4;
            white-space: pre-wrap;
            word-break: break-word;
        }

        .message.incoming .message-bubble {
            background: #f1f5f9; /* Màu xám nhạt cho AI trong light mode */
            color: #1e293b;
            border-bottom-left-radius: 4px;
        }

        .message.outgoing .message-bubble {
            background: #a333c8; /* Giữ màu tím cho người dùng */
            color: white;
            border-bottom-right-radius: 4px;
        }

        .message-time {
            font-size: 0.7rem;
            color: #94a3b8;
            margin-top: 2px;
            padding: 0 10px;
            display: none;
        }

        .message:hover .message-time {
            display: block;
        }

        .message.outgoing .message-time {
            text-align: right;
        }

        .message-bubble b, .message-bubble strong {
            font-weight: 700;
            color: inherit;
        }

        .message.incoming .message-bubble b, .message.incoming .message-bubble strong {
            color: #0f172a;
        }

        .typing-indicator {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.6rem 1rem;
            background: #f1f5f9;
            border-radius: 18px;
            border-bottom-left-radius: 4px;
            width: fit-content;
        }

        .typing-dots {
            display: flex;
            gap: 4px;
        }

        .typing-dots span {
            width: 6px;
            height: 6px;
            background: #94a3b8;
            border-radius: 50%;
            animation: typing 1.4s infinite ease-in-out;
        }

        .typing-dots span:nth-child(1) { animation-delay: 0s; }
        .typing-dots span:nth-child(2) { animation-delay: 0.2s; }
        .typing-dots span:nth-child(3) { animation-delay: 0.4s; }

        @keyframes typing {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-3px); }
        }

        .chat-input-area {
            padding: 1.25rem 1.5rem;
            border-top: 1px solid #f1f5f9;
            background: white;
        }

        .chat-form {
            display: flex;
            gap: 0.75rem;
            align-items: center;
        }

        .chat-input {
            flex: 1;
            padding: 0.7rem 1.25rem;
            border: none;
            background: #f1f5f9;
            color: #1e293b;
            border-radius: 20px;
            font-size: 0.95rem;
            transition: all 0.2s ease;
            outline: none;
        }

        .chat-input::placeholder {
            color: #94a3b8;
        }

        .btn-send {
            width: 40px;
            height: 40px;
            padding: 0;
            background: transparent;
            color: #a333c8;
            border: none;
            border-radius: 50%;
            font-size: 1.25rem;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .btn-send span {
            display: none; /* Ẩn chữ "Gửi" chỉ để lại icon */
        }

        .btn-send:hover {
            background: rgba(163, 51, 200, 0.1);
            transform: scale(1.1);
        }

        /* Language Switcher */
        .lang-switcher {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 0.75rem;
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            cursor: pointer;
            font-size: 0.875rem;
            font-weight: 500;
            color: #64748b;
            transition: all 0.2s ease;
        }

        .lang-switcher:hover {
            border-color: var(--primary-color);
            color: var(--primary-color);
        }

        .lang-switcher i {
            font-size: 1rem;
        }

        .lang-dropdown {
            position: absolute;
            top: 100%;
            right: 0;
            margin-top: 0.5rem;
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
            min-width: 140px;
            z-index: 100;
            display: none;
        }

        .lang-dropdown.active {
            display: block;
        }

        .lang-option {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.75rem 1rem;
            cursor: pointer;
            transition: all 0.2s ease;
            font-size: 0.875rem;
        }

        .lang-option:hover {
            background: #f8fafc;
        }

        .lang-option.active {
            background: rgba(45, 187, 188, 0.1);
            color: var(--primary-color);
            font-weight: 600;
        }

        .lang-flag {
            font-size: 1.125rem;
        }

        /* Quick Actions */
        .quick-actions {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 1rem;
            flex-wrap: wrap;
        }

        .quick-action-btn {
            padding: 0.5rem 1rem;
            background: #f1f5f9;
            border: none;
            border-radius: 20px;
            font-size: 0.875rem;
            color: #64748b;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .quick-action-btn:hover {
            background: rgba(45, 187, 188, 0.1);
            color: var(--primary-color);
        }

        /* Sidebar Panel */
        .info-panel {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }

        .panel-card {
            background: white;
            border-radius: 16px;
            padding: 1.5rem;
            border: 1px solid #e2e8f0;
        }

        .panel-title {
            font-size: 1rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .panel-title i {
            color: var(--primary-color);
        }

        .health-metrics {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }

        .metric-item {
            text-align: center;
            padding: 1rem;
            background: #f8fafc;
            border-radius: 12px;
            transition: all 0.2s ease;
        }

        .metric-item:hover {
            background: rgba(45, 187, 188, 0.05);
        }

        .metric-value {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--primary-color);
        }

        .metric-label {
            font-size: 0.75rem;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .suggestion-list {
            list-style: none;
        }

        .suggestion-item {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.75rem 0;
            border-bottom: 1px solid #f1f5f9;
            font-size: 0.875rem;
            color: #64748b;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .suggestion-item:last-child {
            border-bottom: none;
        }

        .suggestion-item:hover {
            color: var(--primary-color);
        }

        .suggestion-item i {
            color: var(--primary-color);
            font-size: 1rem;
        }

        .ai-note {
            background: linear-gradient(135deg, rgba(45, 187, 188, 0.1), rgba(35, 148, 149, 0.05));
            border-radius: 12px;
            padding: 1rem;
            font-size: 0.875rem;
            color: #64748b;
            line-height: 1.6;
        }

        .ai-note strong {
            color: var(--primary-color);
        }

        /* Responsive */
        @media (max-width: 1200px) {
            .chat-layout {
                grid-template-columns: 1fr;
            }

            .info-panel {
                flex-direction: row;
                overflow-x: auto;
            }

            .panel-card {
                min-width: 300px;
            }
        }

        @media (max-width: 768px) {
            .sidebar-modern {
                width: var(--sidebar-collapsed);
            }

            .sidebar-modern .brand-text,
            .sidebar-modern .user-info,
            .sidebar-modern .nav-text {
                display: none;
            }

            .main-content-dash {
                margin-left: var(--sidebar-collapsed);
            }

            .chat-layout {
                height: auto;
            }

            .message-content {
                max-width: 85%;
            }
        }

        /* Modal Styles - Shared with Dashboard */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(4px);
            z-index: 2000;
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
        }

        .modal-overlay.active {
            opacity: 1;
            visibility: visible;
        }

        .modal-container {
            background: white;
            border-radius: 20px;
            width: 90%;
            max-width: 500px;
            max-height: 85vh;
            overflow-y: auto;
            box-shadow: 0 25px 80px rgba(0, 0, 0, 0.2);
            transform: scale(0.9) translateY(20px);
            transition: all 0.3s ease;
        }

        .modal-overlay.active .modal-container {
            transform: scale(1) translateY(0);
        }

        .modal-header {
            padding: 1.5rem 2rem;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-header h3 {
            margin: 0;
            font-size: 1.25rem;
            font-weight: 700;
            color: #1e293b;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .modal-header h3 i {
            color: var(--primary-color);
        }

        .modal-close {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            border: none;
            background: #f1f5f9;
            color: #64748b;
            font-size: 1.5rem;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .modal-close:hover {
            background: #fee2e2;
            color: #ef4444;
        }

        .modal-body {
            padding: 1.5rem 2rem;
        }

        .modal-footer {
            padding: 1.25rem 2rem;
            border-top: 1px solid #e2e8f0;
            display: flex;
            justify-content: flex-end;
            gap: 0.75rem;
        }

        .btn-modal-primary {
            padding: 0.75rem 1.5rem;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            color: white;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .btn-modal-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(45, 187, 188, 0.35);
        }

        .btn-modal-secondary {
            padding: 0.75rem 1.5rem;
            background: #f1f5f9;
            color: #64748b;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .btn-modal-secondary:hover {
            background: #e2e8f0;
            color: #475569;
        }

        /* Settings Tabs */
        .settings-tabs {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 1.5rem;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 0.5rem;
        }

        .tab-btn {
            padding: 0.625rem 1.25rem;
            border: none;
            background: transparent;
            color: #64748b;
            font-weight: 500;
            cursor: pointer;
            border-radius: 8px;
            transition: all 0.2s ease;
        }

        .tab-btn:hover {
            background: #f1f5f9;
            color: #475569;
        }

        .tab-btn.active {
            background: rgba(45, 187, 188, 0.1);
            color: var(--primary-color);
        }

        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
            animation: fadeIn 0.3s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .settings-form {
            display: flex;
            flex-direction: column;
            gap: 1.25rem;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 0.375rem;
        }

        .form-group label {
            font-size: 0.875rem;
            font-weight: 500;
            color: #374151;
        }

        .form-group input,
        .form-group select,
        .form-group textarea {
            padding: 0.625rem 0.875rem;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            font-size: 0.9375rem;
            transition: all 0.2s ease;
        }

        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(45, 187, 188, 0.1);
        }

        /* Toggle Switch */
        .toggle-list {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .toggle-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem;
            background: #f8fafc;
            border-radius: 10px;
        }

        .toggle-info h5 {
            font-size: 0.9375rem;
            font-weight: 600;
            color: #1e293b;
            margin: 0 0 0.25rem 0;
        }

        .toggle-info p {
            font-size: 0.8125rem;
            color: #64748b;
            margin: 0;
        }

        .toggle-switch {
            position: relative;
            width: 48px;
            height: 26px;
        }

        .toggle-switch input {
            opacity: 0;
            width: 0;
            height: 0;
        }

        .toggle-slider {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #e2e8f0;
            transition: .3s;
            border-radius: 26px;
        }

        .toggle-slider:before {
            position: absolute;
            content: "";
            height: 20px;
            width: 20px;
            left: 3px;
            bottom: 3px;
            background-color: white;
            transition: .3s;
            border-radius: 50%;
        }

        input:checked + .toggle-slider {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
        }

        input:checked + .toggle-slider:before {
            transform: translateX(22px);
        }

        /* Theme Options */
        .theme-options {
            display: flex;
            gap: 1rem;
        }

        .theme-option {
            flex: 1;
            cursor: pointer;
        }

        .theme-option input {
            display: none;
        }

        .theme-option span {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            padding: 0.75rem;
            background: #f1f5f9;
            border-radius: 8px;
            font-size: 0.875rem;
            color: #64748b;
            transition: all 0.2s ease;
        }

        .theme-option.active span,
        .theme-option input:checked + span {
            background: rgba(45, 187, 188, 0.1);
            color: var(--primary-color);
            font-weight: 600;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .modal-container {
                width: 95%;
            }

            .form-row {
                grid-template-columns: 1fr;
            }

            .settings-tabs {
                flex-wrap: wrap;
            }
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <aside class="sidebar-modern">
        <div class="sidebar-header">
            <a href="../index.jsp" class="brand-dashboard">
                <div class="brand-icon-dash">
                    <i class="bi bi-heart-pulse-fill"></i>
                </div>
                <span class="brand-text">DiabetesCare</span>
            </a>
        </div>

        <div class="user-profile">
            <div class="user-avatar">${sessionScope.currentUser.fullName.charAt(0)}</div>
            <div class="user-info">
                <h6>${sessionScope.currentUser.fullName}</h6>
                <small>${sessionScope.currentUser.email}</small>
            </div>
        </div>

        <nav class="sidebar-nav">
            <a href="dashboard.jsp" class="nav-item-dash">
                <i class="bi bi-grid-fill"></i>
                <span class="nav-text" data-i18n="overview">Overview</span>
            </a>
            <a href="chat.jsp" class="nav-item-dash active">
                <i class="bi bi-chat-dots"></i>
                <span class="nav-text" data-i18n="aiChat">AI Chat</span>
            </a>
            <a href="dashboard.jsp" class="nav-item-dash">
                <i class="bi bi-file-medical"></i>
                <span class="nav-text" data-i18n="medicalHistory">Medical History</span>
            </a>
            <a href="dashboard.jsp" class="nav-item-dash">
                <i class="bi bi-bell"></i>
                <span class="nav-text" data-i18n="notifications">Notifications</span>
            </a>
            <a href="#" class="nav-item-dash" onclick="showSettings(); return false;">
                <i class="bi bi-gear"></i>
                <span class="nav-text" data-i18n="settings">Settings</span>
            </a>
        </nav>

        <div class="sidebar-footer">
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                <i class="bi bi-box-arrow-left"></i>
                <span class="nav-text" data-i18n="logout">Logout</span>
            </a>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="main-content-dash">
        <!-- Header -->
        <div class="dash-header">
            <div class="welcome-section">
                <h1 data-i18n="aiHealthAssistant">AI Health <span>Assistant</span></h1>
                <p data-i18n="chatSubtitle">Chat with your personal AI to track symptoms and get health insights.</p>
            </div>
            <div style="display: flex; gap: 0.75rem; align-items: center;">
                <div style="position: relative;">
                    <button class="lang-switcher" onclick="toggleLangDropdown()">
                        <i class="bi bi-globe"></i>
                        <span id="currentLang">English</span>
                        <i class="bi bi-chevron-down" style="font-size: 0.75rem;"></i>
                    </button>
                    <div class="lang-dropdown" id="langDropdown">
                        <div class="lang-option active" onclick="switchLanguage('en')">
                            <span class="lang-flag">🇺🇸</span>
                            <span>English</span>
                        </div>
                        <div class="lang-option" onclick="switchLanguage('vi')">
                            <span class="lang-flag">🇻🇳</span>
                            <span>Tiếng Việt</span>
                        </div>
                    </div>
                </div>
                <div class="status-badge-ai">
                    <span data-i18n="aiStatus">AI Online</span>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="quick-actions">
            <button class="quick-action-btn" onclick="sendQuickMessage(currentLanguage === 'vi' ? 'Đường huyết hôm nay' : 'My glucose level today')">
                <i class="bi bi-droplet"></i> <span data-i18n="logGlucose">Log Glucose</span>
            </button>
            <button class="quick-action-btn" onclick="sendQuickMessage(currentLanguage === 'vi' ? 'Tôi bị đau đầu' : 'I have a headache')">
                <i class="bi bi-emoji-dizzy"></i> <span data-i18n="reportSymptom">Report Symptom</span>
            </button>
            <button class="quick-action-btn" onclick="sendQuickMessage(currentLanguage === 'vi' ? 'Tôi nên ăn gì?' : 'What should I eat?')">
                <i class="bi bi-egg-fried"></i> <span data-i18n="dietAdvice">Diet Advice</span>
            </button>
            <button class="quick-action-btn" onclick="sendQuickMessage(currentLanguage === 'vi' ? 'Huyết áp của tôi' : 'My blood pressure')">
                <i class="bi bi-heart-pulse"></i> <span data-i18n="logBP">Log BP</span>
            </button>
        </div>

        <!-- Chat Layout -->
        <div class="chat-layout">
            <!-- Chat Container -->
            <div class="chat-container">
                <div class="chat-header">
                    <div class="ai-avatar">
                        <i class="bi bi-robot"></i>
                    </div>
                    <div class="ai-info">
                        <h5 data-i18n="drAiAssistant">Dr. AI Assistant</h5>
                        <p data-i18n="aiAlwaysHere">Always here to help with your health questions</p>
                    </div>
                </div>

                <div class="chat-messages" id="chatWindow">
                    <!-- Welcome Message -->
                    <div class="message incoming">
                        <div class="message-avatar ai">
                            <i class="bi bi-robot"></i>
                        </div>
                        <div class="message-content">
                            <div class="message-bubble" data-i18n="aiWelcomeMessage">
                                Hello! I'm your AI health assistant. I'm here to help you track your health, answer questions about diabetes, and provide guidance. How are you feeling today? 😊
                            </div>
                            <div class="message-time" data-i18n="justNow">Just now</div>
                        </div>
                    </div>
                </div>

                <div class="chat-input-area">
                    <form class="chat-form" id="chatForm">
                        <input 
                            type="text" 
                            class="chat-input" 
                            id="chatInput" 
                            placeholder="Type your message here..." 
                            autocomplete="off"
                            required
                            data-i18n-placeholder="typeMessage"
                        />
                        <button type="submit" class="btn-send">
                            <i class="bi bi-send-fill"></i>
                            <span data-i18n="send">Send</span>
                        </button>
                    </form>
                </div>
            </div>

            <!-- Info Panel -->
            <div class="info-panel">
                <!-- Health Summary -->
                <div class="panel-card">
                    <h5 class="panel-title">
                        <i class="bi bi-heart-pulse"></i>
                        Health Summary
                    </h5>
                    <div class="health-metrics">
                        <div class="metric-item">
                            <div class="metric-value" id="summaryHba1c">0</div>
                            <div class="metric-label">HbA1c</div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-value" id="summaryBMI">0</div>
                            <div class="metric-label">BMI</div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-value" id="summaryTG">0</div>
                            <div class="metric-label">TG</div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-value" id="summaryHDL">0</div>
                            <div class="metric-label">HDL</div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-value" id="summarySymptoms">0</div>
                            <div class="metric-label" data-i18n="symptoms">Symptoms</div>
                        </div>
                    </div>
                </div>

                <!-- Quick Suggestions -->
                <div class="panel-card">
                    <h5 class="panel-title">
                        <i class="bi bi-lightbulb"></i>
                        Suggested Topics
                    </h5>
                    <ul class="suggestion-list">
                        <li class="suggestion-item" onclick="sendQuickMessage('What are normal glucose levels?')">
                            <i class="bi bi-question-circle"></i>
                            Normal glucose ranges
                        </li>
                        <li class="suggestion-item" onclick="sendQuickMessage('Tips for managing diabetes')">
                            <i class="bi bi-question-circle"></i>
                            Diabetes management tips
                        </li>
                        <li class="suggestion-item" onclick="sendQuickMessage('Healthy meal suggestions')">
                            <i class="bi bi-question-circle"></i>
                            Healthy meal ideas
                        </li>
                        <li class="suggestion-item" onclick="sendQuickMessage('When should I see a doctor?')">
                            <i class="bi bi-question-circle"></i>
                            When to see a doctor
                        </li>
                    </ul>
                </div>

                <!-- AI Note -->
                <div class="panel-card" style="background: linear-gradient(135deg, var(--primary-color), var(--primary-dark)); color: white; border: none;">
                    <h5 class="panel-title" style="color: white;">
                        <i class="bi bi-info-circle"></i>
                        About AI Assistant
                    </h5>
                    <p style="font-size: 0.875rem; opacity: 0.9; line-height: 1.6; margin: 0;">
                        This AI assistant helps collect your health information and provides general guidance. <strong>Always consult your doctor</strong> for medical decisions.
                    </p>
                </div>
            </div>
        </div>
    </main>

    <!-- Settings Modal -->
    <div class="modal-overlay" id="settingsModal">
        <div class="modal-container">
            <div class="modal-header">
                <h3><i class="bi bi-gear"></i> Settings</h3>
                <button class="modal-close" onclick="closeModal('settingsModal')">&times;</button>
            </div>
            <div class="modal-body">
                <div class="settings-tabs">
                    <button class="tab-btn active" onclick="switchTab('profile')">Profile</button>
                    <button class="tab-btn" onclick="switchTab('notifications')">Notifications</button>
                    <button class="tab-btn" onclick="switchTab('preferences')">Preferences</button>
                </div>

                <!-- Profile Tab -->
                <div class="tab-content active" id="profileTab">
                    <div class="settings-form">
                        <div class="form-row">
                            <div class="form-group">
                                <label>Full Name</label>
                                <input type="text" value="${sessionScope.currentUser.fullName}" id="settingName">
                            </div>
                            <div class="form-group">
                                <label>Email</label>
                                <input type="email" value="${sessionScope.currentUser.email}" id="settingEmail">
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label>Phone</label>
                                <input type="tel" value="${sessionScope.currentUser.phone}" id="settingPhone">
                            </div>
                            <div class="form-group">
                                <label>Date of Birth</label>
                                <input type="date" value="${sessionScope.currentUser.dob}" id="settingDob">
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Address</label>
                            <textarea rows="2" id="settingAddress">${sessionScope.currentUser.address}</textarea>
                        </div>
                    </div>
                </div>

                <!-- Notifications Tab -->
                <div class="tab-content" id="notificationsTab">
                    <div class="settings-form">
                        <div class="toggle-list">
                            <div class="toggle-item">
                                <div class="toggle-info">
                                    <h5>Email Notifications</h5>
                                    <p>Receive updates about appointments</p>
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" checked>
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>
                            <div class="toggle-item">
                                <div class="toggle-info">
                                    <h5>Medication Reminders</h5>
                                    <p>Daily reminders for medication</p>
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" checked>
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Preferences Tab -->
                <div class="tab-content" id="preferencesTab">
                    <div class="settings-form">
                        <div class="form-group">
                            <label>Language</label>
                            <select>
                                <option value="en" selected>English</option>
                                <option value="vi">Vietnamese</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Theme</label>
                            <div class="theme-options">
                                <label class="theme-option active">
                                    <input type="radio" name="theme" value="light" checked>
                                    <span><i class="bi bi-sun"></i> Light</span>
                                </label>
                                <label class="theme-option">
                                    <input type="radio" name="theme" value="dark">
                                    <span><i class="bi bi-moon"></i> Dark</span>
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-modal-secondary" onclick="closeModal('settingsModal')">Cancel</button>
                <button class="btn-modal-primary" onclick="saveSettings()">
                    <i class="bi bi-check-lg"></i> Save
                </button>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="../js/chat.js"></script>
    <script>
        // Quick message function
        function sendQuickMessage(text) {
            const input = document.getElementById('chatInput');
            input.value = text;
            input.focus();
        }

        // Modal functions
        function openModal(modalId) {
            document.getElementById(modalId).classList.add('active');
            document.body.style.overflow = 'hidden';
        }

        function closeModal(modalId) {
            document.getElementById(modalId).classList.remove('active');
            document.body.style.overflow = '';
        }

        // Settings function
        function showSettings() {
            openModal('settingsModal');
        }

        // Tab switching
        function switchTab(tabName) {
            document.querySelectorAll('.tab-content').forEach(tab => {
                tab.classList.remove('active');
            });
            document.querySelectorAll('.tab-btn').forEach(btn => {
                btn.classList.remove('active');
            });
            document.getElementById(tabName + 'Tab').classList.add('active');
            event.target.classList.add('active');
        }

        // Save settings
        function saveSettings() {
            const name = document.getElementById('settingName').value;
            alert('✅ Settings Saved Successfully!\n\nName: ' + name);
            closeModal('settingsModal');
        }

        // Close modal on overlay click
        document.querySelectorAll('.modal-overlay').forEach(overlay => {
            overlay.addEventListener('click', function(e) {
                if (e.target === this) {
                    this.classList.remove('active');
                    document.body.style.overflow = '';
                }
            });
        });

        // Escape key to close modals
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                document.querySelectorAll('.modal-overlay.active').forEach(modal => {
                    modal.classList.remove('active');
                });
                document.body.style.overflow = '';
            }
        });

        // ==========================================
        // LANGUAGE TRANSLATION SYSTEM
        // ==========================================

        const translations = {
            en: {
                // Header & Sidebar
                aiHealthAssistant: 'AI Health Assistant',
                chatSubtitle: 'Chat with your personal AI to track symptoms and get health insights.',
                aiStatus: 'AI Online',
                overview: 'Overview',
                aiChat: 'AI Chat',
                medicalHistory: 'Medical History',
                notifications: 'Notifications',
                settings: 'Settings',
                logout: 'Logout',

                // Quick Actions
                logGlucose: 'Log Glucose',
                reportSymptom: 'Report Symptom',
                dietAdvice: 'Diet Advice',
                logBP: 'Log BP',

                // Chat
                drAiAssistant: 'Dr. AI Assistant',
                aiAlwaysHere: 'Always here to help with your health questions',
                aiWelcomeMessage: "Hello! I'm your AI health assistant. I'm here to help you track your health, answer questions about diabetes, and provide guidance. How are you feeling today? 😊",
                justNow: 'Just now',
                typeMessage: 'Type your message here...',
                send: 'Send',

                // Info Panel
                healthSummary: 'Health Summary',
                hba1c: 'HbA1c',
                bmi: 'BMI',
                tg: 'TG',
                hdl: 'HDL',
                symptoms: 'Symptoms',
                suggestedTopics: 'Suggested Topics',
                aboutAi: 'About AI Assistant',
                aboutAiText: 'This AI assistant helps collect your health information and provides general guidance. Always consult your doctor for medical decisions.',

                // Settings
                profile: 'Profile',
                notifications: 'Notifications',
                preferences: 'Preferences',
                save: 'Save',
                cancel: 'Cancel',
                fullName: 'Full Name',
                email: 'Email',
                phone: 'Phone',
                language: 'Language',
                theme: 'Theme',
                light: 'Light',
                dark: 'Dark'
            },
            vi: {
                // Header & Sidebar
                aiHealthAssistant: 'Trợ lý AI Sức khỏe',
                chatSubtitle: 'Chat với AI cá nhân để theo dõi triệu chứng và nhận thông tin sức khỏe.',
                aiStatus: 'AI Trực tuyến',
                overview: 'Tổng quan',
                aiChat: 'Chat AI',
                medicalHistory: 'Lịch sử khám',
                notifications: 'Thông báo',
                settings: 'Cài đặt',
                logout: 'Đăng xuất',

                // Quick Actions
                logGlucose: 'Ghi đường huyết',
                reportSymptom: 'Báo cáo triệu chứng',
                dietAdvice: 'Tư vấn dinh dưỡng',
                logBP: 'Ghi huyết áp',

                // Chat
                drAiAssistant: 'Bác sĩ AI',
                aiAlwaysHere: 'Luôn sẵn sàng hỗ trợ các câu hỏi về sức khỏe',
                aiWelcomeMessage: 'Xin chào! Tôi là trợ lý AI sức khỏe của bạn. Tôi ở đây để giúp bạn theo dõi sức khỏe, trả lời câu hỏi về tiểu đường và cung cấp hướng dẫn. Hôm nay bạn cảm thấy thế nào? 😊',
                justNow: 'Vừa xong',
                typeMessage: 'Nhập tin nhắn của bạn...',
                send: 'Gửi',

                // Info Panel
                healthSummary: 'Tổng quan sức khỏe',
                hba1c: 'HbA1c',
                bmi: 'BMI',
                tg: 'TG',
                hdl: 'HDL',
                symptoms: 'Triệu chứng',
                suggestedTopics: 'Chủ đề gợi ý',
                aboutAi: 'Về Trợ lý AI',
                aboutAiText: 'Trợ lý AI này giúp thu thập thông tin sức khỏe và cung cấp hướng dẫn chung. Luôn tham khảo ý kiến bác sĩ cho các quyết định y tế.',

                // Settings
                profile: 'Hồ sơ',
                notifications: 'Thông báo',
                preferences: 'Tùy chọn',
                save: 'Lưu',
                cancel: 'Hủy',
                fullName: 'Họ tên',
                email: 'Email',
                phone: 'Điện thoại',
                language: 'Ngôn ngữ',
                theme: 'Giao diện',
                light: 'Sáng',
                dark: 'Tối'
            }
        };

        let currentLanguage = localStorage.getItem('diabetesAppLang') || 'en';

        // Toggle language dropdown
        function toggleLangDropdown() {
            const dropdown = document.getElementById('langDropdown');
            dropdown.classList.toggle('active');
        }

        // Close dropdown when clicking outside
        document.addEventListener('click', function(e) {
            const dropdown = document.getElementById('langDropdown');
            const switcher = e.target.closest('.lang-switcher');
            if (!switcher && dropdown) {
                dropdown.classList.remove('active');
            }
        });

        // Switch language
        function switchLanguage(lang) {
            currentLanguage = lang;
            localStorage.setItem('diabetesAppLang', lang);

            // Update active state in dropdown
            document.querySelectorAll('.lang-option').forEach(opt => {
                opt.classList.remove('active');
            });
            event.target.closest('.lang-option').classList.add('active');

            // Update current language display
            const langNames = { en: 'English', vi: 'Tiếng Việt' };
            document.getElementById('currentLang').textContent = langNames[lang];

            // Apply translations
            applyTranslations();

            // Close dropdown
            document.getElementById('langDropdown').classList.remove('active');
        }

        // Apply translations
        function applyTranslations() {
            const t = translations[currentLanguage];

            // Update all elements with data-i18n attribute
            document.querySelectorAll('[data-i18n]').forEach(el => {
                const key = el.getAttribute('data-i18n');
                if (t[key]) {
                    if (el.querySelector('i, span')) {
                        const icon = el.querySelector('i');
                        const span = el.querySelector('span');
                        if (span && span.getAttribute('data-i18n') === key) {
                            span.textContent = t[key];
                        } else if (!icon && !span) {
                            el.textContent = t[key];
                        } else {
                            // Keep icon, update text
                            const text = document.createTextNode(' ' + t[key]);
                            el.childNodes.forEach(node => {
                                if (node.nodeType === Node.TEXT_NODE && node.textContent.trim()) {
                                    node.remove();
                                }
                            });
                            el.appendChild(text);
                        }
                    } else {
                        el.textContent = t[key];
                    }
                }
            });

            // Update placeholders
            document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
                const key = el.getAttribute('data-i18n-placeholder');
                if (t[key]) {
                    el.placeholder = t[key];
                }
            });

            // Update modal title
            const settingsTitle = document.querySelector('#settingsModal .modal-header h3');
            if (settingsTitle) {
                settingsTitle.innerHTML = '<i class="bi bi-gear"></i> ' + (currentLanguage === 'vi' ? 'Cài đặt' : 'Settings');
            }
        }

        // Initialize language on page load
        document.addEventListener('DOMContentLoaded', function() {
            const savedLang = localStorage.getItem('diabetesAppLang');
            if (savedLang === 'vi') {
                document.getElementById('currentLang').textContent = 'Tiếng Việt';
                document.querySelectorAll('.lang-option').forEach(opt => {
                    opt.classList.remove('active');
                    if (opt.textContent.includes('Tiếng Việt')) {
                        opt.classList.add('active');
                    }
                });
                applyTranslations();
            }
        });
    </script>
</body>
</html>
