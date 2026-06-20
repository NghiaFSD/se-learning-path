<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.LocalDate" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Patient Dashboard - DiabetesCare</title>
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

        /* Sidebar */
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

        .dash-actions {
            display: flex;
            gap: 0.75rem;
        }

        .btn-dash-primary {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 12px;
            text-decoration: none;
            font-weight: 600;
            border: none;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .btn-dash-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(45, 187, 188, 0.35);
            color: white;
        }

        .btn-dash-outline {
            background: white;
            color: #64748b;
            padding: 0.75rem 1.5rem;
            border-radius: 12px;
            text-decoration: none;
            font-weight: 600;
            border: 2px solid #e2e8f0;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .btn-dash-outline:hover {
            border-color: var(--primary-color);
            color: var(--primary-color);
        }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card-dash {
            background: white;
            border-radius: 16px;
            padding: 1.5rem;
            border: 1px solid #e2e8f0;
            transition: all 0.3s ease;
        }

        .stat-card-dash:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.08);
            border-color: transparent;
        }

        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            margin-bottom: 1rem;
        }

        .stat-icon.glucose {
            background: rgba(45, 187, 188, 0.1);
            color: var(--primary-color);
        }

        .stat-icon.risk {
            background: rgba(245, 158, 11, 0.1);
            color: #f59e0b;
        }

        .stat-icon.calendar {
            background: rgba(99, 102, 241, 0.1);
            color: #6366f1;
        }

        .stat-icon.medicine {
            background: rgba(16, 185, 129, 0.1);
            color: #10b981;
        }

        .stat-label-dash {
            color: #64748b;
            font-size: 0.875rem;
            font-weight: 500;
            margin-bottom: 0.5rem;
        }

        .stat-value {
            font-size: 1.5rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 0.25rem;
        }

        .stat-trend {
            font-size: 0.875rem;
            color: #10b981;
            font-weight: 500;
        }

        .stat-trend.warning {
            color: #f59e0b;
        }

        /* Content Grid */
        .content-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 1.5rem;
            margin-bottom: 1.5rem;
        }

        .dash-card {
            background: white;
            border-radius: 16px;
            padding: 1.5rem;
            border: 1px solid #e2e8f0;
        }

        .dash-card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }

        .dash-card-title {
            font-size: 1.125rem;
            font-weight: 700;
            color: #1e293b;
            margin: 0;
        }

        .btn-card-action {
            padding: 0.5rem 1rem;
            background: #f1f5f9;
            border: none;
            border-radius: 8px;
            color: #64748b;
            font-size: 0.875rem;
            font-weight: 500;
            transition: all 0.2s ease;
        }

        .btn-card-action:hover {
            background: var(--primary-color);
            color: white;
        }

        /* Chart */
        .chart-container {
            background: linear-gradient(135deg, #f8fafc, #f1f5f9);
            border-radius: 12px;
            padding: 1.5rem;
        }

        .chart-bars {
            display: flex;
            align-items: flex-end;
            justify-content: space-around;
            height: 200px;
            gap: 1rem;
            margin-bottom: 1rem;
        }

        .chart-bar-item {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 0.5rem;
        }

        .bar-visual {
            width: 100%;
            background: linear-gradient(to top, var(--primary-color), #5dd3d4);
            border-radius: 8px 8px 0 0;
            min-height: 40px;
            display: flex;
            align-items: flex-start;
            justify-content: center;
            padding-top: 0.5rem;
            color: white;
            font-weight: 600;
            font-size: 0.875rem;
            transition: all 0.3s ease;
        }

        .bar-visual:hover {
            opacity: 0.85;
        }

        .bar-label {
            font-size: 0.75rem;
            color: #64748b;
            font-weight: 500;
        }

        /* AI Risk Card */
        .ai-risk-card {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            border-radius: 12px;
            padding: 1.25rem;
            color: white;
            margin-bottom: 1.5rem;
        }

        .ai-risk-header {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 0.75rem;
            font-size: 0.875rem;
            opacity: 0.9;
        }

        .ai-risk-level {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        .ai-risk-desc {
            font-size: 0.875rem;
            opacity: 0.9;
            line-height: 1.5;
        }

        .recommendations {
            margin-top: 1.5rem;
        }

        .recommendations h6 {
            font-size: 0.875rem;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 0.75rem;
        }

        .rec-list {
            list-style: none;
        }

        .rec-list li {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.875rem;
            color: #64748b;
            margin-bottom: 0.5rem;
        }

        .rec-list li i {
            color: var(--primary-color);
            font-size: 1rem;
        }

        /* Table */
        .dash-table {
            width: 100%;
            border-collapse: collapse;
        }

        .dash-table th {
            text-align: left;
            padding: 0.75rem;
            font-size: 0.75rem;
            font-weight: 600;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            background: #f8fafc;
        }

        .dash-table td {
            padding: 1rem 0.75rem;
            border-bottom: 1px solid #e2e8f0;
            font-size: 0.875rem;
        }

        .dash-table tr:last-child td {
            border-bottom: none;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.375rem;
            padding: 0.375rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .status-badge.success {
            background: rgba(16, 185, 129, 0.1);
            color: #10b981;
        }

        .status-badge.warning {
            background: rgba(245, 158, 11, 0.1);
            color: #f59e0b;
        }

        /* Notifications */
        .notification-item {
            display: flex;
            gap: 1rem;
            padding: 1rem 0;
            border-bottom: 1px solid #e2e8f0;
        }

        .notification-item:last-child {
            border-bottom: none;
        }

        .notif-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .notif-icon.info {
            background: rgba(45, 187, 188, 0.1);
            color: var(--primary-color);
        }

        .notif-icon.alert {
            background: rgba(245, 158, 11, 0.1);
            color: #f59e0b;
        }

        .notif-icon.success {
            background: rgba(16, 185, 129, 0.1);
            color: #10b981;
        }

        .notif-content {
            flex: 1;
        }

        .notif-time {
            font-size: 0.75rem;
            color: #94a3b8;
            margin-bottom: 0.25rem;
        }

        .notif-text {
            font-size: 0.875rem;
            color: #1e293b;
            line-height: 1.4;
        }

        /* Responsive */
        @media (max-width: 1200px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .content-grid {
                grid-template-columns: 1fr;
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

            .stats-grid {
                grid-template-columns: 1fr;
            }

            .dash-header {
                flex-direction: column;
                gap: 1rem;
            }
        }

        /* Modal Styles */
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
            max-width: 600px;
            max-height: 85vh;
            overflow-y: auto;
            box-shadow: 0 25px 80px rgba(0, 0, 0, 0.2);
            transform: scale(0.9) translateY(20px);
            transition: all 0.3s ease;
        }

        .modal-overlay.active .modal-container {
            transform: scale(1) translateY(0);
        }

        .modal-container.modal-large {
            max-width: 900px;
        }

        .modal-header {
            padding: 1.5rem 2rem;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            background: white;
            z-index: 10;
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
            padding: 2rem;
        }

        .modal-footer {
            padding: 1.25rem 2rem;
            border-top: 1px solid #e2e8f0;
            display: flex;
            justify-content: flex-end;
            gap: 0.75rem;
            position: sticky;
            bottom: 0;
            background: white;
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

        /* Report Modal Styles */
        .report-stats {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1rem;
            margin-bottom: 2rem;
        }

        .report-stat-item {
            text-align: center;
            padding: 1.25rem;
            background: linear-gradient(135deg, #f8fafc, #f1f5f9);
            border-radius: 12px;
        }

        .report-stat-value {
            font-size: 1.75rem;
            font-weight: 800;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .report-stat-label {
            font-size: 0.75rem;
            color: #64748b;
            margin-top: 0.25rem;
        }

        .report-chart-detailed {
            margin-bottom: 2rem;
        }

        .report-chart-detailed h4 {
            font-size: 1rem;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 1rem;
        }

        .detailed-chart {
            display: flex;
            gap: 1rem;
            height: 250px;
            background: #f8fafc;
            border-radius: 12px;
            padding: 1.5rem;
        }

        .chart-y-axis {
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            color: #64748b;
            font-size: 0.75rem;
            padding-right: 0.5rem;
        }

        .chart-area {
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .trend-line {
            flex: 1;
            width: 100%;
        }

        .chart-x-labels {
            display: flex;
            justify-content: space-between;
            color: #64748b;
            font-size: 0.75rem;
            margin-top: 0.5rem;
        }

        .report-recommendations h4 {
            font-size: 1rem;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .recommendation-box {
            background: #f8fafc;
            border-radius: 12px;
            padding: 1.25rem;
        }

        .rec-item {
            display: flex;
            align-items: flex-start;
            gap: 0.75rem;
            padding: 0.75rem 0;
            border-bottom: 1px solid #e2e8f0;
            font-size: 0.875rem;
            color: #475569;
        }

        .rec-item:last-child {
            border-bottom: none;
        }

        .rec-item i {
            font-size: 1.125rem;
            margin-top: 0.125rem;
        }

        /* History Modal Styles */
        .history-filters {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
            gap: 1rem;
        }

        .filter-group {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .filter-group label {
            font-size: 0.875rem;
            color: #64748b;
        }

        .filter-group select {
            padding: 0.5rem 1rem;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            font-size: 0.875rem;
            background: white;
            cursor: pointer;
        }

        .search-box {
            position: relative;
        }

        .search-box i {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
        }

        .search-box input {
            padding: 0.5rem 1rem 0.5rem 2.5rem;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            font-size: 0.875rem;
            width: 200px;
        }

        .history-timeline {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }

        .timeline-item {
            display: flex;
            gap: 1.5rem;
        }

        .timeline-date {
            width: 80px;
            text-align: center;
            flex-shrink: 0;
        }

        .date-day {
            display: block;
            font-size: 1.5rem;
            font-weight: 800;
            color: var(--primary-color);
            line-height: 1;
        }

        .date-month {
            font-size: 0.75rem;
            color: #64748b;
            text-transform: uppercase;
        }

        .timeline-content {
            flex: 1;
        }

        .timeline-card {
            background: #f8fafc;
            border-radius: 12px;
            padding: 1.25rem;
            border-left: 4px solid var(--primary-color);
        }

        .timeline-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.75rem;
        }

        .timeline-header h5 {
            font-size: 1rem;
            font-weight: 600;
            color: #1e293b;
            margin: 0;
        }

        .timeline-details {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            margin-bottom: 0.75rem;
        }

        .detail-row {
            display: flex;
            gap: 1.5rem;
            font-size: 0.875rem;
            color: #64748b;
        }

        .detail-row i {
            color: var(--primary-color);
        }

        .timeline-notes {
            font-size: 0.875rem;
            color: #64748b;
            font-style: italic;
            margin: 0;
            padding-top: 0.75rem;
            border-top: 1px solid #e2e8f0;
        }

        /* Settings Modal Styles */
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

        .form-hint {
            font-size: 0.75rem;
            color: #94a3b8;
            margin-top: 0.25rem;
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

        /* Notification Badge */
        .notif-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 20px;
            height: 20px;
            padding: 0 6px;
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
            font-size: 0.75rem;
            font-weight: 700;
            border-radius: 10px;
            margin-left: 0.5rem;
        }

        /* User Profile Hover Effect */
        .user-profile {
            transition: all 0.2s ease;
        }

        .user-profile:hover {
            background: rgba(45, 187, 188, 0.05);
        }

        .user-profile:hover .user-avatar {
            transform: scale(1.05);
            box-shadow: 0 4px 12px rgba(45, 187, 188, 0.3);
        }

        .user-avatar {
            transition: all 0.2s ease;
        }

        /* Notifications Modal Specific Styles */
        .notifications-list {
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
            max-height: 400px;
            overflow-y: auto;
        }

        .notification-modal-item {
            display: flex;
            gap: 1rem;
            padding: 1rem;
            background: #f8fafc;
            border-radius: 12px;
            border-left: 4px solid transparent;
            transition: all 0.2s ease;
            cursor: pointer;
        }

        .notification-modal-item:hover {
            background: rgba(45, 187, 188, 0.05);
            border-left-color: var(--primary-color);
        }

        .notification-modal-item.unread {
            background: rgba(45, 187, 188, 0.08);
            border-left-color: var(--primary-color);
        }

        .notif-modal-icon {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            font-size: 1.25rem;
        }

        .notif-modal-icon.alert {
            background: rgba(245, 158, 11, 0.1);
            color: #f59e0b;
        }

        .notif-modal-icon.info {
            background: rgba(45, 187, 188, 0.1);
            color: var(--primary-color);
        }

        .notif-modal-icon.success {
            background: rgba(16, 185, 129, 0.1);
            color: #10b981;
        }

        .notif-modal-content {
            flex: 1;
        }

        .notif-modal-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 0.25rem;
        }

        .notif-modal-title {
            font-weight: 600;
            color: #1e293b;
            font-size: 0.9375rem;
        }

        .notif-modal-time {
            font-size: 0.75rem;
            color: #94a3b8;
            white-space: nowrap;
        }

        .notif-modal-text {
            font-size: 0.875rem;
            color: #64748b;
            line-height: 1.4;
            margin: 0;
        }

        .notif-modal-actions {
            display: flex;
            gap: 0.5rem;
            margin-top: 0.75rem;
        }

        .notif-action-btn {
            padding: 0.375rem 0.75rem;
            border: none;
            background: white;
            color: #64748b;
            border-radius: 6px;
            font-size: 0.75rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .notif-action-btn:hover {
            background: var(--primary-color);
            color: white;
        }

        .notifications-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 1rem;
            border-top: 1px solid #e2e8f0;
            margin-top: 1rem;
        }

        .mark-all-read {
            padding: 0.5rem 1rem;
            border: none;
            background: transparent;
            color: var(--primary-color);
            font-size: 0.875rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .mark-all-read:hover {
            background: rgba(45, 187, 188, 0.1);
            border-radius: 8px;
        }

        /* Responsive Modals */
        @media (max-width: 768px) {
            .modal-container {
                width: 95%;
                max-height: 90vh;
            }

            .modal-body {
                padding: 1.25rem;
            }

            .report-stats {
                grid-template-columns: repeat(2, 1fr);
            }

            .form-row {
                grid-template-columns: 1fr;
            }

            .history-filters {
                flex-direction: column;
                align-items: stretch;
            }

            .search-box input {
                width: 100%;
            }

            .timeline-item {
                flex-direction: column;
                gap: 0.75rem;
            }

            .timeline-date {
                display: flex;
                align-items: center;
                gap: 0.5rem;
                width: auto;
            }

            .date-day {
                font-size: 1.25rem;
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

        <div class="user-profile" onclick="showSettingsTab('profile')" style="cursor: pointer;" title="Click to edit profile">
            <div class="user-avatar">${sessionScope.currentUser.fullName.charAt(0)}</div>
            <div class="user-info">
                <h6>${sessionScope.currentUser.fullName} <i class="bi bi-pencil-square" style="font-size: 0.75rem; color: var(--primary-color);"></i></h6>
                <small>${sessionScope.currentUser.email}</small>
            </div>
        </div>

        <nav class="sidebar-nav">
            <a href="dashboard.jsp" class="nav-item-dash active">
                <i class="bi bi-grid-fill"></i>
                <span class="nav-text" data-i18n="overview">Overview</span>
            </a>
            <a href="chat.jsp" class="nav-item-dash">
                <i class="bi bi-chat-dots"></i>
                <span class="nav-text" data-i18n="aiChat">AI Chat</span>
            </a>
            <a href="#" class="nav-item-dash" onclick="scrollToHistory(); return false;">
                <i class="bi bi-file-medical"></i>
                <span class="nav-text" data-i18n="medicalHistory">Medical History</span>
            </a>
            <a href="#" class="nav-item-dash" onclick="showSettingsTab('profile'); return false;">
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
                <h1 data-i18n="welcome">Welcome back, <span>${sessionScope.currentUser.fullName}</span></h1>
                <p data-i18n="subtitle">Here's your health summary and AI-assisted insights for today.</p>
            </div>
            <div class="dash-actions">
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
                <a href="chat.jsp" class="btn-dash-outline" data-i18n="aiChat">
                    <i class="bi bi-robot"></i>
                    AI Chat
                </a>
                <button class="btn-dash-primary" onclick="window.location.reload()">
                    <i class="bi bi-arrow-clockwise"></i>
                    <span data-i18n="refresh">Refresh</span>
                </button>
            </div>
        </div>

        <!-- Welcome & Health Record Submission -->
        <div class="welcome-banner" style="background: linear-gradient(135deg, var(--primary-color), var(--primary-dark)); color: white; padding: 2rem; border-radius: 16px; margin-bottom: 2rem;">
            <h3 style="margin-bottom: 0.5rem;"><i class="bi bi-heart-pulse"></i> <span data-i18n="healthSubmission">Submit Health Record</span></h3>
            <p data-i18n="healthSubmissionDesc">Enter your health information for AI-assisted monitoring and doctor review.</p>
        </div>

        <!-- Health Record Submission Form -->
        <div class="dash-card" style="margin-bottom: 2rem;">
            <div class="dash-card-header">
                <h5 class="dash-card-title">
                    <i class="bi bi-clipboard-plus me-2" style="color: var(--primary-color);"></i>
                    <span data-i18n="newHealthRecord">New Health Record</span>
                </h5>
                <span class="badge bg-warning" data-i18n="pendingSubmission">Pending Submission</span>
            </div>
            <div style="padding: 1.5rem;">
                <form id="healthRecordForm" action="submit-health-record" method="POST">
                    <div class="row g-3">
                        <!-- Lab Test Indicators -->
                        <div class="col-md-3">
                            <label class="form-label" data-i18n="urea">Urea (mmol/L)</label>
                            <input type="number" step="0.01" class="form-control" name="urea" id="urea" placeholder="e.g., 5.2">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label" data-i18n="cr">Creatinine (Cr) (μmol/L)</label>
                            <input type="number" step="0.01" class="form-control" name="cr" id="cr" placeholder="e.g., 85">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label" data-i18n="hba1c">HbA1c (%)</label>
                            <input type="number" step="0.01" class="form-control" name="hba1c" id="hba1c" placeholder="e.g., 6.5">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label" data-i18n="chol">Cholesterol (mmol/L)</label>
                            <input type="number" step="0.01" class="form-control" name="chol" id="chol" placeholder="e.g., 4.5">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label" data-i18n="tg">Triglycerides (TG) (mmol/L)</label>
                            <input type="number" step="0.01" class="form-control" name="tg" id="tg" placeholder="e.g., 1.8">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label" data-i18n="hdl">HDL (mmol/L)</label>
                            <input type="number" step="0.01" class="form-control" name="hdl" id="hdl" placeholder="e.g., 1.2">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label" data-i18n="ldl">LDL (mmol/L)</label>
                            <input type="number" step="0.01" class="form-control" name="ldl" id="ldl" placeholder="e.g., 2.8">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label" data-i18n="vldl">VLDL (mmol/L)</label>
                            <input type="number" step="0.01" class="form-control" name="vldl" id="vldl" placeholder="e.g., 0.8">
                        </div>
                        
                        <!-- Body Measurements -->
                        <div class="col-md-4">
                            <label class="form-label" data-i18n="weight">Weight (kg)</label>
                            <input type="number" step="0.1" class="form-control" name="weight" id="weight" placeholder="e.g., 70.5">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label" data-i18n="height">Height (cm)</label>
                            <input type="number" step="0.1" class="form-control" name="height" id="height" placeholder="e.g., 170">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">BMI (auto-calculated)</label>
                            <input type="number" step="0.01" class="form-control" name="bmi" id="bmi" readonly placeholder="Will be calculated">
                        </div>
                        
                        <!-- Other Information -->
                        <div class="col-12">
                            <label class="form-label" data-i18n="otherInformation">Other Information</label>
                            <textarea class="form-control" name="other_information" id="other_information" rows="3" 
                                placeholder="Symptoms, blood pressure, medical history, lifestyle, etc."></textarea>
                        </div>
                        
                        <!-- Submit Buttons -->
                        <div class="col-12 d-flex gap-2 justify-content-end">
                            <button type="button" class="btn btn-outline-secondary" onclick="resetForm()" data-i18n="reset">Reset</button>
                            <a href="chat.jsp" class="btn btn-outline-primary" data-i18n="chatWithAIConfirm">
                                <i class="bi bi-chat-dots"></i> Chat with AI to Confirm
                            </a>
                            <button type="submit" class="btn btn-primary" style="background: var(--primary-color); border-color: var(--primary-color);" data-i18n="submitRecord">
                                <i class="bi bi-send"></i> Submit Record
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Bottom Grid -->
        <div class="content-grid">
            <!-- Medical History -->
            <div class="dash-card" id="history">
                <div class="dash-card-header">
                    <h5 class="dash-card-title">
                        <i class="bi bi-file-medical me-2" style="color: var(--primary-color);"></i>
                        <span data-i18n="medicalHistoryTitle">Medical History</span>
                    </h5>
                    <button class="btn-card-action" onclick="viewAllHistory()" data-i18n="viewAll">View All</button>
                </div>
                <table class="dash-table">
                    <thead>
                        <tr>
                            <th data-i18n="date">Date</th>
                            <th data-i18n="glucose">Glucose</th>
                            <th data-i18n="bmi">BMI</th>
                            <th data-i18n="bloodPressure">Blood Pressure</th>
                            <th data-i18n="status">Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>2026-05-12</td>
                            <td><strong>7.8 mmol/L</strong></td>
                            <td>26.2</td>
                            <td>130/85 mmHg</td>
                            <td>
                                <span class="status-badge warning">
                                    <i class="bi bi-exclamation-circle"></i>
                                    Moderate
                                </span>
                            </td>
                        </tr>
                        <tr>
                            <td>2026-04-25</td>
                            <td><strong>7.4 mmol/L</strong></td>
                            <td>25.9</td>
                            <td>128/82 mmHg</td>
                            <td>
                                <span class="status-badge success">
                                    <i class="bi bi-check-circle"></i>
                                    <span data-i18n="stable">Stable</span>
                                </span>
                            </td>
                        </tr>
                        <tr>
                            <td>2026-04-10</td>
                            <td><strong>7.0 mmol/L</strong></td>
                            <td>26.0</td>
                            <td>125/80 mmHg</td>
                            <td>
                                <span class="status-badge success">
                                    <i class="bi bi-check-circle"></i>
                                    <span data-i18n="stable">Stable</span>
                                </span>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <!-- Full History Modal -->
    <div class="modal-overlay" id="historyModal">
        <div class="modal-container modal-large">
            <div class="modal-header">
                <h3><i class="bi bi-file-medical"></i> Complete Medical History</h3>
                <button class="modal-close" onclick="closeModal('historyModal')">&times;</button>
            </div>
            <div class="modal-body">
                <div class="history-filters">
                    <div class="filter-group">
                        <label data-i18n="filterBy">Filter by:</label>
                        <select id="historyFilter" onchange="filterHistory()">
                            <option value="all" data-i18n="allRecords">All Records</option>
                            <option value="recent" data-i18n="last3Months">Last 3 Months</option>
                            <option value="stable" data-i18n="stableStatus">Stable Status</option>
                            <option value="attention" data-i18n="needsAttention">Needs Attention</option>
                        </select>
                    </div>
                    <div class="search-box">
                        <i class="bi bi-search"></i>
                        <input type="text" placeholder="Search records..." id="historySearch" data-i18n-placeholder="searchRecords">
                    </div>
                </div>

                <div class="history-timeline">
                    <div class="timeline-item">
                        <div class="timeline-date">
                            <span class="date-day">12</span>
                            <span class="date-month">May 2026</span>
                        </div>
                        <div class="timeline-content">
                            <div class="timeline-card">
                                <div class="timeline-header">
                                    <h5 data-i18n="regularCheckup">Regular Checkup</h5>
                                    <span class="status-badge warning" data-i18n="moderate">Moderate</span>
                                </div>
                                <div class="timeline-details">
                                    <div class="detail-row">
                                        <span><i class="bi bi-droplet"></i> <span data-i18n="glucose">Glucose</span>: <strong>7.8 mmol/L</strong></span>
                                        <span><i class="bi bi-rulers"></i> <span data-i18n="bmi">BMI</span>: <strong>26.2</strong></span>
                                    </div>
                                    <div class="detail-row">
                                        <span><i class="bi bi-heart-pulse"></i> <span data-i18n="bpShort">BP</span>: <strong>130/85 mmHg</strong></span>
                                        <span><i class="bi bi-person"></i> Doctor: <strong>Dr. Nguyen</strong></span>
                                    </div>
                                </div>
                                <p class="timeline-notes" data-i18n="note1">Patient reported mild fatigue. Recommended lifestyle adjustments.</p>
                            </div>
                        </div>
                    </div>

                    <div class="timeline-item">
                        <div class="timeline-date">
                            <span class="date-day">25</span>
                            <span class="date-month">Apr 2026</span>
                        </div>
                        <div class="timeline-content">
                            <div class="timeline-card">
                                <div class="timeline-header">
                                    <h5 data-i18n="followUpVisit">Follow-up Visit</h5>
                                    <span class="status-badge success" data-i18n="stable">Stable</span>
                                </div>
                                <div class="timeline-details">
                                    <div class="detail-row">
                                        <span><i class="bi bi-droplet"></i> <span data-i18n="glucose">Glucose</span>: <strong>7.4 mmol/L</strong></span>
                                        <span><i class="bi bi-rulers"></i> <span data-i18n="bmi">BMI</span>: <strong>25.9</strong></span>
                                    </div>
                                    <div class="detail-row">
                                        <span><i class="bi bi-heart-pulse"></i> <span data-i18n="bpShort">BP</span>: <strong>128/82 mmHg</strong></span>
                                        <span><i class="bi bi-person"></i> <span data-i18n="doctor">Doctor</span>: <strong>Dr. Tran</strong></span>
                                    </div>
                                </div>
                                <p class="timeline-notes" data-i18n="note2">Good progress. Continue current medication and diet plan.</p>
                            </div>
                        </div>
                    </div>

                    <div class="timeline-item">
                        <div class="timeline-date">
                            <span class="date-day">10</span>
                            <span class="date-month">Apr 2026</span>
                        </div>
                        <div class="timeline-content">
                            <div class="timeline-card">
                                <div class="timeline-header">
                                    <h5 data-i18n="initialConsultation">Initial Consultation</h5>
                                    <span class="status-badge success" data-i18n="stable">Stable</span>
                                </div>
                                <div class="timeline-details">
                                    <div class="detail-row">
                                        <span><i class="bi bi-droplet"></i> <span data-i18n="glucose">Glucose</span>: <strong>7.0 mmol/L</strong></span>
                                        <span><i class="bi bi-rulers"></i> <span data-i18n="bmi">BMI</span>: <strong>26.0</strong></span>
                                    </div>
                                    <div class="detail-row">
                                        <span><i class="bi bi-heart-pulse"></i> <span data-i18n="bpShort">BP</span>: <strong>125/80 mmHg</strong></span>
                                        <span><i class="bi bi-person"></i> <span data-i18n="doctor">Doctor</span>: <strong>Dr. Nguyen</strong></span>
                                    </div>
                                </div>
                                <p class="timeline-notes" data-i18n="note3">Initial assessment completed. Baseline vitals established.</p>
                            </div>
                        </div>
                    </div>

                    <div class="timeline-item">
                        <div class="timeline-date">
                            <span class="date-day">15</span>
                            <span class="date-month">Mar 2026</span>
                        </div>
                        <div class="timeline-content">
                            <div class="timeline-card">
                                <div class="timeline-header">
                                    <h5>Emergency Visit</h5>
                                    <span class="status-badge" style="background: rgba(239, 68, 68, 0.1); color: #ef4444;">Critical</span>
                                </div>
                                <div class="timeline-details">
                                    <div class="detail-row">
                                        <span><i class="bi bi-droplet"></i> Glucose: <strong>9.2 mmol/L</strong></span>
                                        <span><i class="bi bi-rulers"></i> BMI: <strong>26.5</strong></span>
                                    </div>
                                    <div class="detail-row">
                                        <span><i class="bi bi-heart-pulse"></i> BP: <strong>145/95 mmHg</strong></span>
                                        <span><i class="bi bi-person"></i> Doctor: <strong>Dr. Lee</strong></span>
                                    </div>
                                </div>
                                <p class="timeline-notes">High glucose spike due to medication skip. Emergency intervention provided.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-modal-secondary" onclick="closeModal('historyModal')" data-i18n="close">Close</button>
                <button class="btn-modal-primary" onclick="printHistory()">
                    <i class="bi bi-printer"></i> <span data-i18n="printHistory">Print History</span>
                </button>
            </div>
        </div>
    </div>

    <!-- Settings Modal -->
    <div class="modal-overlay" id="settingsModal">
        <div class="modal-container">
            <div class="modal-header">
                <h3><i class="bi bi-gear"></i> Settings</h3>
                <button class="modal-close" onclick="closeModal('settingsModal')">&times;</button>
            </div>
            <div class="modal-body">
                <div class="settings-header" style="margin-bottom: 1.5rem;">
                    <h5 data-i18n="editProfile">Edit Profile</h5>
                    <p class="text-muted" data-i18n="editProfileDesc">Update your personal information</p>
                </div>

                <!-- Only Profile Tab - Edit Personal Information -->
                <div class="tab-content active" id="profileTab">
                    <div class="settings-form">
                        <div class="form-row">
                            <div class="form-group">
                                <label data-i18n="fullName">Full Name</label>
                                <input type="text" value="${sessionScope.currentUser.fullName}" id="settingName">
                            </div>
                            <div class="form-group">
                                <label data-i18n="email">Email</label>
                                <input type="email" value="${sessionScope.currentUser.email}" id="settingEmail" readonly>
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label data-i18n="phone">Phone</label>
                                <input type="tel" value="${sessionScope.currentUser.phone}" id="settingPhone">
                            </div>
                            <div class="form-group">
                                <label data-i18n="dateOfBirth">Date of Birth</label>
                                <input type="date" value="${sessionScope.currentUser.dob}" id="settingDob">
                            </div>
                        </div>
                        <div class="form-group">
                            <label data-i18n="address">Address</label>
                            <textarea rows="2" id="settingAddress">${sessionScope.currentUser.address}</textarea>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-modal-secondary" onclick="closeModal('settingsModal')" data-i18n="cancel">Cancel</button>
                <button class="btn-modal-primary" onclick="saveSettings()">
                    <i class="bi bi-check-lg"></i> <span data-i18n="saveChanges">Save Changes</span>
                </button>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Scroll to Medical History
        function scrollToHistory() {
            document.getElementById('history').scrollIntoView({ behavior: 'smooth' });
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

        // View All History
        function viewAllHistory() {
            openModal('historyModal');
        }

        // Show Settings Modal with Profile
        function showSettingsTab(tabName) {
            fetch('update-profile', { method: 'GET', credentials: 'same-origin' })
                .then(r => r.json())
                .then(data => {
                    if (data.error) { alert('Cannot load profile: ' + data.error); return; }
                    document.getElementById('settingName').value    = data.fullName  || '';
                    document.getElementById('settingEmail').value   = data.email     || '';
                    document.getElementById('settingPhone').value   = data.phone     || '';
                    document.getElementById('settingDob').value     = data.dob       || '';
                    document.getElementById('settingAddress').value = data.address   || '';
                })
                .catch(() => {});
            openModal('settingsModal');
        }

        // Calculate BMI automatically
        function calculateBMI() {
            const weight = parseFloat(document.getElementById('weight').value);
            const height = parseFloat(document.getElementById('height').value);
            if (weight > 0 && height > 0) {
                const heightInMeters = height / 100;
                const bmi = weight / (heightInMeters * heightInMeters);
                document.getElementById('bmi').value = bmi.toFixed(2);
            }
        }

        // Reset Health Record Form
        function resetForm() {
            document.getElementById('healthRecordForm').reset();
            document.getElementById('bmi').value = '';
        }

        // Add event listeners for BMI calculation
        document.addEventListener('DOMContentLoaded', function() {
            const weightInput = document.getElementById('weight');
            const heightInput = document.getElementById('height');
            if (weightInput && heightInput) {
                weightInput.addEventListener('input', calculateBMI);
                heightInput.addEventListener('input', calculateBMI);
            }
        });

        // Save settings
        function saveSettings() {
            const params = new URLSearchParams();
            params.append('fullName', document.getElementById('settingName').value);
            params.append('phone',    document.getElementById('settingPhone').value);
            params.append('dob',      document.getElementById('settingDob').value);
            params.append('address',  document.getElementById('settingAddress').value);
            fetch('update-profile', {
                method: 'POST',
                credentials: 'same-origin',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            })
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    document.querySelectorAll('.user-name, .sidebar-user-name').forEach(el => {
                        el.textContent = document.getElementById('settingName').value;
                    });
                    alert('✅ Thông tin đã được lưu thành công!');
                    closeModal('settingsModal');
                } else {
                    alert('Lưu thất bại: ' + (data.error || 'Lỗi không xác định'));
                }
            })
            .catch(() => alert('Lỗi kết nối, vui lòng thử lại.'));
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

        // Translation data
        const translations = {
            en: {
                // Header & Sidebar
                welcome: 'Welcome back,',
                subtitle: 'Submit your health record for AI-assisted monitoring and doctor review.',
                aiChat: 'AI Chat',
                refresh: 'Refresh',
                overview: 'Overview',
                medicalHistory: 'Medical History',
                settings: 'Settings',
                logout: 'Logout',

                // Health Record Form
                healthSubmission: 'Submit Health Record',
                healthSubmissionDesc: 'Enter your health information for AI-assisted monitoring and doctor review.',
                newHealthRecord: 'New Health Record',
                pendingSubmission: 'Pending Submission',
                urea: 'Urea (mmol/L)',
                cr: 'Creatinine (Cr) (μmol/L)',
                hba1c: 'HbA1c (%)',
                chol: 'Cholesterol (mmol/L)',
                tg: 'Triglycerides (TG) (mmol/L)',
                hdl: 'HDL (mmol/L)',
                ldl: 'LDL (mmol/L)',
                vldl: 'VLDL (mmol/L)',
                weight: 'Weight (kg)',
                height: 'Height (cm)',
                otherInformation: 'Other Information',
                reset: 'Reset',
                submitRecord: 'Submit Record',
                chatWithAIConfirm: 'Chat with AI to Confirm',

                // History
                medicalHistoryTitle: 'Medical History',
                viewAll: 'View All',
                date: 'Date',
                status: 'Status',
                stable: 'Stable',

                // Modals
                close: 'Close',
                saveChanges: 'Save Changes',
                cancel: 'Cancel',

                // Settings Modal
                fullName: 'Full Name',
                dateOfBirth: 'Date of Birth',
                address: 'Address',
                phone: 'Phone',
                email: 'Email',
                editProfile: 'Edit Profile',
                editProfileDesc: 'Update your personal information'
            },
            vi: {
                // Header & Sidebar
                welcome: 'Xin chào,',
                subtitle: 'Gửi hồ sơ sức khỏe để được AI hỗ trợ và bác sĩ xem xét.',
                aiChat: 'Chat AI',
                refresh: 'Làm mới',
                overview: 'Tổng quan',
                medicalHistory: 'Lịch sử khám',
                settings: 'Cài đặt',
                logout: 'Đăng xuất',

                // Health Record Form
                healthSubmission: 'Gửi Hồ Sơ Sức Khỏe',
                healthSubmissionDesc: 'Nhập thông tin sức khỏe để được AI hỗ trợ và bác sĩ xem xét.',
                newHealthRecord: 'Hồ Sơ Sức Khỏe Mới',
                pendingSubmission: 'Chờ Gửi',
                urea: 'Ure (mmol/L)',
                cr: 'Creatinine (Cr) (μmol/L)',
                hba1c: 'HbA1c (%)',
                chol: 'Cholesterol (mmol/L)',
                tg: 'Triglycerides (TG) (mmol/L)',
                hdl: 'HDL (mmol/L)',
                ldl: 'LDL (mmol/L)',
                vldl: 'VLDL (mmol/L)',
                weight: 'Cân nặng (kg)',
                height: 'Chiều cao (cm)',
                otherInformation: 'Thông tin khác',
                reset: 'Làm lại',
                submitRecord: 'Gửi Hồ Sơ',
                chatWithAIConfirm: 'Chat với AI để Xác nhận',

                // History
                medicalHistoryTitle: 'Lịch sử y tế',
                viewAll: 'Xem tất cả',
                date: 'Ngày',
                status: 'Trạng thái',
                stable: 'Ổn định',

                // Modals
                close: 'Đóng',
                saveChanges: 'Lưu thay đổi',
                cancel: 'Hủy',

                // Settings Modal
                fullName: 'Họ tên',
                dateOfBirth: 'Ngày sinh',
                address: 'Địa chỉ',
                phone: 'Điện thoại',
                email: 'Email',
                editProfile: 'Chỉnh sửa Hồ sơ',
                editProfileDesc: 'Cập nhật thông tin cá nhân của bạn'
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

        // Apply translations to all elements
        function applyTranslations() {
            const t = translations[currentLanguage];

            // Update all elements with data-i18n attribute
            document.querySelectorAll('[data-i18n]').forEach(el => {
                const key = el.getAttribute('data-i18n');
                if (t[key]) {
                    // Keep any child elements (like icons, spans)
                    if (el.querySelector('i, span')) {
                        // Find text nodes and update them
                        Array.from(el.childNodes).forEach(node => {
                            if (node.nodeType === Node.TEXT_NODE && node.textContent.trim()) {
                                node.textContent = ' ' + t[key] + ' ';
                            }
                        });
                        // If no text nodes, just set content
                        if (!el.querySelector('i, span')) {
                            el.textContent = t[key];
                        } else {
                            // For mixed content, set only the text part
                            const icon = el.querySelector('i');
                            const span = el.querySelector('span');
                            if (span && span.getAttribute('data-i18n') === key) {
                                span.textContent = t[key];
                            } else if (!icon && !span) {
                                el.textContent = t[key];
                            }
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

            // Update modal titles and buttons
            updateModalTranslations();
        }

        // Update modal translations
        function updateModalTranslations() {
            const t = translations[currentLanguage];

            // Report Modal
            const reportTitle = document.querySelector('#reportModal .modal-header h3');
            if (reportTitle) {
                reportTitle.innerHTML = '<i class="bi bi-graph-up"></i> ' + (currentLanguage === 'vi' ? 'Báo cáo đường huyết' : 'Detailed Glucose Report');
            }

            // History Modal
            const historyTitle = document.querySelector('#historyModal .modal-header h3');
            if (historyTitle) {
                historyTitle.innerHTML = '<i class="bi bi-file-medical"></i> ' + (currentLanguage === 'vi' ? 'Lịch sử khám bệnh' : 'Complete Medical History');
            }

            // Settings Modal
            const settingsTitle = document.querySelector('#settingsModal .modal-header h3');
            if (settingsTitle) {
                settingsTitle.innerHTML = '<i class="bi bi-gear"></i> ' + (currentLanguage === 'vi' ? 'Cài đặt' : 'Settings');
            }

            // Update all buttons with data-i18n
            document.querySelectorAll('button[data-i18n]').forEach(btn => {
                const key = btn.getAttribute('data-i18n');
                if (t[key]) {
                    // Preserve icon if exists
                    const icon = btn.querySelector('i');
                    if (icon) {
                        btn.innerHTML = '';
                        btn.appendChild(icon);
                        btn.appendChild(document.createTextNode(' ' + t[key]));
                    } else {
                        btn.textContent = t[key];
                    }
                }
            });
        }

        // Initialize language on page load
        document.addEventListener('DOMContentLoaded', function() {
            const savedLang = localStorage.getItem('diabetesAppLang');
            if (savedLang === 'vi') {
                // Update language display
                document.getElementById('currentLang').textContent = 'Tiếng Việt';
                // Update active option
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
