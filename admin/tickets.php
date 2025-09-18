<?php
require_once '../config/database.php';
requireAdmin();

$error = '';
$success = '';

// Handle ticket actions
if ($_POST) {
    if (!verifyCSRFToken($_POST['csrf_token'] ?? '')) {
        $error = 'Invalid request. Please try again.';
    } else {
        $action = $_POST['action'] ?? '';
        $ticket_id = (int)($_POST['ticket_id'] ?? 0);
        
        switch ($action) {
            case 'respond_ticket':
                $response = sanitize($_POST['response'] ?? '');
                $new_status = sanitize($_POST['status'] ?? 'in_progress');
                
                if (empty($response)) {
                    $error = 'Please enter a response.';
                } else {
                    // Get ticket details
                    $stmt = $db->prepare("SELECT * FROM support_tickets WHERE id = ?");
                    $stmt->execute([$ticket_id]);
                    $ticket = $stmt->fetch();
                    
                    if ($ticket) {
                        $stmt = $db->prepare("
                            UPDATE support_tickets 
                            SET admin_response = ?, status = ?, responded_by = ?, updated_at = NOW() 
                            WHERE id = ?
                        ");
                        
                        if ($stmt->execute([$response, $new_status, $_SESSION['user_id'], $ticket_id])) {
                            $success = 'Response sent successfully.';
                            
                            // Send notification to user
                            sendNotification(
                                $ticket['user_id'],
                                'Support Ticket Updated',
                                "Your support ticket #$ticket_id has been updated with a new response.",
                                'info'
                            );
                        } else {
                            $error = 'Failed to send response.';
                        }
                    } else {
                        $error = 'Ticket not found.';
                    }
                }
                break;
                
            case 'update_status':
                $new_status = sanitize($_POST['status'] ?? '');
                $valid_statuses = ['open', 'in_progress', 'resolved', 'closed'];
                
                if (in_array($new_status, $valid_statuses)) {
                    $stmt = $db->prepare("
                        UPDATE support_tickets 
                        SET status = ?, updated_at = NOW() 
                        WHERE id = ?
                    ");
                    
                    if ($stmt->execute([$new_status, $ticket_id])) {
                        $success = 'Ticket status updated successfully.';
                    } else {
                        $error = 'Failed to update ticket status.';
                    }
                } else {
                    $error = 'Invalid status selected.';
                }
                break;
                
            case 'update_priority':
                $new_priority = sanitize($_POST['priority'] ?? '');
                $valid_priorities = ['low', 'medium', 'high', 'urgent'];
                
                if (in_array($new_priority, $valid_priorities)) {
                    $stmt = $db->prepare("
                        UPDATE support_tickets 
                        SET priority = ?, updated_at = NOW() 
                        WHERE id = ?
                    ");
                    
                    if ($stmt->execute([$new_priority, $ticket_id])) {
                        $success = 'Ticket priority updated successfully.';
                    } else {
                        $error = 'Failed to update ticket priority.';
                    }
                } else {
                    $error = 'Invalid priority selected.';
                }
                break;
        }
    }
}

// Get filter parameters
$status_filter = $_GET['status'] ?? 'all';
$priority_filter = $_GET['priority'] ?? 'all';
$page = max(1, (int)($_GET['page'] ?? 1));
$limit = 20;
$offset = ($page - 1) * $limit;

// Build query conditions
$where_conditions = ["1=1"];
$params = [];

if ($status_filter !== 'all') {
    $where_conditions[] = "st.status = ?";
    $params[] = $status_filter;
}

if ($priority_filter !== 'all') {
    $where_conditions[] = "st.priority = ?";
    $params[] = $priority_filter;
}

$where_clause = implode(' AND ', $where_conditions);

// Get total count
$count_sql = "SELECT COUNT(*) as total FROM support_tickets st WHERE $where_clause";
$stmt = $db->prepare($count_sql);
$stmt->execute($params);
$total_records = $stmt->fetch()['total'];
$total_pages = ceil($total_records / $limit);

// Get tickets
$sql = "
    SELECT st.*, 
           u.full_name, u.email,
           admin.full_name as admin_name
    FROM support_tickets st
    JOIN users u ON st.user_id = u.id
    LEFT JOIN users admin ON st.responded_by = admin.id
    WHERE $where_clause
    ORDER BY 
        CASE st.priority 
            WHEN 'urgent' THEN 1
            WHEN 'high' THEN 2 
            WHEN 'medium' THEN 3
            WHEN 'low' THEN 4
        END,
        st.created_at DESC
    LIMIT $limit OFFSET $offset
";

$stmt = $db->prepare($sql);
$stmt->execute($params);
$tickets = $stmt->fetchAll();

// Get summary statistics
$stats_sql = "
    SELECT 
        COUNT(*) as total_tickets,
        COUNT(CASE WHEN status = 'open' THEN 1 END) as open_tickets,
        COUNT(CASE WHEN status = 'in_progress' THEN 1 END) as in_progress_tickets,
        COUNT(CASE WHEN status = 'resolved' THEN 1 END) as resolved_tickets,
        COUNT(CASE WHEN status = 'closed' THEN 1 END) as closed_tickets,
        COUNT(CASE WHEN priority = 'urgent' THEN 1 END) as urgent_tickets,
        COUNT(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR) THEN 1 END) as tickets_24h
    FROM support_tickets
";
$stmt = $db->query($stats_sql);
$stats = $stmt->fetch();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Support Tickets - Ultra Harvest Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap');
        * { font-family: 'Poppins', sans-serif; }
        
        .glass-card {
            backdrop-filter: blur(20px);
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .ticket-card {
            transition: all 0.3s ease;
        }
        
        .ticket-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3);
        }
        
        .modal {
            display: none;
            backdrop-filter: blur(10px);
        }
        
        .modal.show {
            display: flex;
        }
        
        .priority-urgent { border-left: 4px solid #ef4444; }
        .priority-high { border-left: 4px solid #f97316; }
        .priority-medium { border-left: 4px solid #eab308; }
        .priority-low { border-left: 4px solid #22c55e; }
    </style>
</head>
<body class="bg-gray-900 text-white min-h-screen">

    <!-- Header -->
    <header class="bg-gray-800/50 backdrop-blur-md border-b border-gray-700 sticky top-0 z-50">
        <div class="container mx-auto px-4">
            <div class="flex items-center justify-between h-16">
                <div class="flex items-center space-x-8">
                    <div class="flex items-center space-x-3">
                        <div class="w-10 h-10 bg-gradient-to-r from-emerald-500 to-yellow-500 rounded-full flex items-center justify-center">
                            <i class="fas fa-seedling text-white"></i>
                        </div>
                        <div>
                            <span class="text-xl font-bold bg-gradient-to-r from-emerald-400 to-yellow-400 bg-clip-text text-transparent">Ultra Harvest</span>
                            <p class="text-xs text-gray-400">Admin Panel</p>
                        </div>
                    </div>
                    
                    <nav class="hidden md:flex space-x-6">
                        <a href="/admin/" class="text-gray-300 hover:text-emerald-400 transition">Dashboard</a>
                        <a href="/admin/users.php" class="text-gray-300 hover:text-emerald-400 transition">Users</a>
                        <a href="/admin/packages.php" class="text-gray-300 hover:text-emerald-400 transition">Packages</a>
                        <a href="/admin/transactions.php" class="text-gray-300 hover:text-emerald-400 transition">Transactions</a>
                        <a href="/admin/tickets.php" class="text-emerald-400 font-medium">Support</a>
                    </nav>
                </div>

                <div class="flex items-center space-x-4">
                    <?php if ($stats['urgent_tickets'] > 0): ?>
                    <div class="flex items-center space-x-2 bg-red-600/20 border border-red-500/50 rounded-full px-3 py-1">
                        <i class="fas fa-exclamation-triangle text-red-400"></i>
                        <span class="text-red-300 text-sm font-medium"><?php echo $stats['urgent_tickets']; ?> Urgent</span>
                    </div>
                    <?php endif; ?>
                    <a href="/logout.php" class="text-red-400 hover:text-red-300">
                        <i class="fas fa-sign-out-alt"></i>
                    </a>
                </div>
            </div>
        </div>
    </header>

    <main class="container mx-auto px-4 py-8">
        
        <!-- Page Header -->
        <div class="flex items-center justify-between mb-8">
            <div>
                <h1 class="text-3xl font-bold text-white">Support Tickets</h1>
                <p class="text-gray-400">Manage customer support requests</p>
            </div>
            <div class="text-right">
                <p class="text-2xl font-bold text-emerald-400"><?php echo number_format($stats['total_tickets']); ?></p>
                <p class="text-gray-400 text-sm">Total Tickets</p>
            </div>
        </div>

        <!-- Error/Success Messages -->
        <?php if ($error): ?>
        <div class="mb-6 p-4 bg-red-500/20 border border-red-500/50 rounded-lg">
            <div class="flex items-center">
                <i class="fas fa-exclamation-circle text-red-400 mr-2"></i>
                <span class="text-red-300"><?php echo $error; ?></span>
            </div>
        </div>
        <?php endif; ?>

        <?php if ($success): ?>
        <div class="mb-6 p-4 bg-emerald-500/20 border border-emerald-500/50 rounded-lg">
            <div class="flex items-center">
                <i class="fas fa-check-circle text-emerald-400 mr-2"></i>
                <span class="text-emerald-300"><?php echo $success; ?></span>
            </div>
        </div>
        <?php endif; ?>

        <!-- Statistics Overview -->
        <section class="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <div class="glass-card rounded-xl p-6">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-400 text-sm">Open Tickets</p>
                        <p class="text-3xl font-bold text-yellow-400"><?php echo number_format($stats['open_tickets']); ?></p>
                    </div>
                    <div class="w-12 h-12 bg-yellow-500/20 rounded-full flex items-center justify-center">
                        <i class="fas fa-ticket-alt text-yellow-400 text-xl"></i>
                    </div>
                </div>
            </div>

            <div class="glass-card rounded-xl p-6">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-400 text-sm">In Progress</p>
                        <p class="text-3xl font-bold text-blue-400"><?php echo number_format($stats['in_progress_tickets']); ?></p>
                    </div>
                    <div class="w-12 h-12 bg-blue-500/20 rounded-full flex items-center justify-center">
                        <i class="fas fa-clock text-blue-400 text-xl"></i>
                    </div>
                </div>
            </div>

            <div class="glass-card rounded-xl p-6">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-400 text-sm">Urgent</p>
                        <p class="text-3xl font-bold text-red-400"><?php echo number_format($stats['urgent_tickets']); ?></p>
                    </div>
                    <div class="w-12 h-12 bg-red-500/20 rounded-full flex items-center justify-center">
                        <i class="fas fa-exclamation-triangle text-red-400 text-xl"></i>
                    </div>
                </div>
            </div>

            <div class="glass-card rounded-xl p-6">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-400 text-sm">Last 24h</p>
                        <p class="text-3xl font-bold text-purple-400"><?php echo number_format($stats['tickets_24h']); ?></p>
                    </div>
                    <div class="w-12 h-12 bg-purple-500/20 rounded-full flex items-center justify-center">
                        <i class="fas fa-history text-purple-400 text-xl"></i>
                    </div>
                </div>
            </div>
        </section>

        <!-- Filters -->
        <section class="glass-card rounded-xl p-6 mb-8">
            <form method="GET" class="grid md:grid-cols-3 gap-4">
                <!-- Status Filter -->
                <div>
                    <label class="block text-sm font-medium text-gray-300 mb-2">Status Filter</label>
                    <select name="status" class="w-full px-3 py-2 bg-gray-800 border border-gray-600 rounded text-white focus:border-emerald-500 focus:outline-none">
                        <option value="all" <?php echo $status_filter === 'all' ? 'selected' : ''; ?>>All Status</option>
                        <option value="open" <?php echo $status_filter === 'open' ? 'selected' : ''; ?>>Open</option>
                        <option value="in_progress" <?php echo $status_filter === 'in_progress' ? 'selected' : ''; ?>>In Progress</option>
                        <option value="resolved" <?php echo $status_filter === 'resolved' ? 'selected' : ''; ?>>Resolved</option>
                        <option value="closed" <?php echo $status_filter === 'closed' ? 'selected' : ''; ?>>Closed</option>
                    </select>
                </div>

                <!-- Priority Filter -->
                <div>
                    <label class="block text-sm font-medium text-gray-300 mb-2">Priority Filter</label>
                    <select name="priority" class="w-full px-3 py-2 bg-gray-800 border border-gray-600 rounded text-white focus:border-emerald-500 focus:outline-none">
                        <option value="all" <?php echo $priority_filter === 'all' ? 'selected' : ''; ?>>All Priorities</option>
                        <option value="urgent" <?php echo $priority_filter === 'urgent' ? 'selected' : ''; ?>>Urgent</option>
                        <option value="high" <?php echo $priority_filter === 'high' ? 'selected' : ''; ?>>High</option>
                        <option value="medium" <?php echo $priority_filter === 'medium' ? 'selected' : ''; ?>>Medium</option>
                        <option value="low" <?php echo $priority_filter === 'low' ? 'selected' : ''; ?>>Low</option>
                    </select>
                </div>

                <!-- Submit -->
                <div class="flex items-end">
                    <button type="submit" class="w-full px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded font-medium transition">
                        <i class="fas fa-filter mr-2"></i>Apply Filters
                    </button>
                </div>
            </form>
        </section>

        <!-- Tickets List -->
        <section class="space-y-4">
            <?php if (empty($tickets)): ?>
                <div class="glass-card rounded-xl p-12 text-center">
                    <i class="fas fa-ticket-alt text-6xl text-gray-600 mb-4"></i>
                    <h3 class="text-xl font-bold text-gray-400 mb-2">No tickets found</h3>
                    <p class="text-gray-500">No support tickets match your current filters</p>
                </div>
            <?php else: ?>
                <?php foreach ($tickets as $ticket): ?>
                <div class="ticket-card glass-card rounded-xl p-6 priority-<?php echo $ticket['priority']; ?>">
                    <div class="flex items-start justify-between mb-4">
                        <div class="flex-1">
                            <div class="flex items-center space-x-3 mb-2">
                                <h3 class="text-xl font-bold text-white"><?php echo htmlspecialchars($ticket['subject']); ?></h3>
                                <span class="text-gray-400 text-sm">#<?php echo $ticket['id']; ?></span>
                            </div>
                            <div class="flex items-center space-x-4 text-sm text-gray-400 mb-3">
                                <span><i class="fas fa-user mr-1"></i><?php echo htmlspecialchars($ticket['full_name']); ?></span>
                                <span><i class="fas fa-envelope mr-1"></i><?php echo htmlspecialchars($ticket['email']); ?></span>
                                <span><i class="fas fa-clock mr-1"></i><?php echo timeAgo($ticket['created_at']); ?></span>
                            </div>
                            <p class="text-gray-300 mb-4"><?php echo nl2br(htmlspecialchars(substr($ticket['message'], 0, 300))); ?>...</p>
                            
                            <?php if ($ticket['admin_response']): ?>
                                <div class="bg-emerald-500/10 border border-emerald-500/30 rounded-lg p-4 mb-4">
                                    <h4 class="text-emerald-400 font-medium mb-2">Your Response:</h4>
                                    <p class="text-gray-300 text-sm"><?php echo nl2br(htmlspecialchars($ticket['admin_response'])); ?></p>
                                    <?php if ($ticket['admin_name']): ?>
                                        <p class="text-emerald-400 text-xs mt-2">- <?php echo htmlspecialchars($ticket['admin_name']); ?></p>
                                    <?php endif; ?>
                                </div>
                            <?php endif; ?>
                        </div>
                        
                        <div class="flex flex-col items-end space-y-2 ml-6">
                            <!-- Status Badge -->
                            <span class="px-3 py-1 rounded-full text-xs font-medium
                                <?php 
                                echo match($ticket['status']) {
                                    'open' => 'bg-blue-500/20 text-blue-400',
                                    'in_progress' => 'bg-yellow-500/20 text-yellow-400',
                                    'resolved' => 'bg-emerald-500/20 text-emerald-400',
                                    'closed' => 'bg-gray-500/20 text-gray-400',
                                    default => 'bg-gray-500/20 text-gray-400'
                                };
                                ?>">
                                <?php echo ucfirst(str_replace('_', ' ', $ticket['status'])); ?>
                            </span>
                            
                            <!-- Priority Badge -->
                            <span class="px-3 py-1 rounded-full text-xs font-medium
                                <?php 
                                echo match($ticket['priority']) {
                                    'urgent' => 'bg-red-500/20 text-red-400',
                                    'high' => 'bg-orange-500/20 text-orange-400',
                                    'medium' => 'bg-yellow-500/20 text-yellow-400',
                                    'low' => 'bg-green-500/20 text-green-400',
                                    default => 'bg-gray-500/20 text-gray-400'
                                };
                                ?>">
                                <?php echo ucfirst($ticket['priority']); ?>
                            </span>
                            
                            <!-- Action Buttons -->
                            <div class="flex space-x-2 mt-4">
                                <button onclick="openTicketModal(<?php echo htmlspecialchars(json_encode($ticket)); ?>)" 
                                        class="px-3 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-sm transition">
                                    <i class="fas fa-reply mr-1"></i>Respond
                                </button>
                                <button onclick="quickStatusUpdate(<?php echo $ticket['id']; ?>, '<?php echo $ticket['status']; ?>')" 
                                        class="px-3 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm transition">
                                    <i class="fas fa-edit mr-1"></i>Update
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <?php endforeach; ?>

                <!-- Pagination -->
                <?php if ($total_pages > 1): ?>
                <div class="flex items-center justify-center mt-8 space-x-2">
                    <?php if ($page > 1): ?>
                        <a href="?status=<?php echo $status_filter; ?>&priority=<?php echo $priority_filter; ?>&page=<?php echo $page-1; ?>" 
                           class="px-4 py-2 bg-gray-800 text-gray-300 rounded-lg hover:bg-gray-700 transition">
                            <i class="fas fa-chevron-left"></i>
                        </a>
                    <?php endif; ?>
                    
                    <?php
                    $start = max(1, $page - 2);
                    $end = min($total_pages, $page + 2);
                    
                    for ($i = $start; $i <= $end; $i++):
                    ?>
                        <a href="?status=<?php echo $status_filter; ?>&priority=<?php echo $priority_filter; ?>&page=<?php echo $i; ?>" 
                           class="px-4 py-2 rounded-lg transition <?php echo $i === $page ? 'bg-emerald-600 text-white' : 'bg-gray-800 text-gray-300 hover:bg-gray-700'; ?>">
                            <?php echo $i; ?>
                        </a>
                    <?php endfor; ?>
                    
                    <?php if ($page < $total_pages): ?>
                        <a href="?status=<?php echo $status_filter; ?>&priority=<?php echo $priority_filter; ?>&page=<?php echo $page+1; ?>" 
                           class="px-4 py-2 bg-gray-800 text-gray-300 rounded-lg hover:bg-gray-700 transition">
                            <i class="fas fa-chevron-right"></i>
                        </a>
                    <?php endif; ?>
                </div>
                <?php endif; ?>
            <?php endif; ?>
        </section>
    </main>

    <!-- Response Modal -->
    <div id="responseModal" class="modal fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
        <div class="glass-card rounded-xl p-6 max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div class="flex items-center justify-between mb-6">
                <h3 class="text-xl font-bold text-white">Respond to Ticket</h3>
                <button onclick="closeModal()" class="text-gray-400 hover:text-white">
                    <i class="fas fa-times text-xl"></i>
                </button>
            </div>
            
            <!-- Ticket Details -->
            <div class="bg-gray-800/50 rounded-lg p-4 mb-6">
                <h4 class="font-bold text-white mb-2" id="modal-subject"></h4>
                <div class="grid grid-cols-2 gap-4 text-sm text-gray-400 mb-3">
                    <div><i class="fas fa-user mr-1"></i><span id="modal-user"></span></div>
                    <div><i class="fas fa-envelope mr-1"></i><span id="modal-email"></span></div>
                    <div><i class="fas fa-clock mr-1"></i><span id="modal-created"></span></div>
                    <div><i class="fas fa-ticket-alt mr-1"></i>#<span id="modal-id"></span></div>
                </div>
                <div class="bg-gray-700/50 rounded p-3">
                    <h5 class="text-gray-300 font-medium mb-2">Original Message:</h5>
                    <p class="text-gray-300 text-sm" id="modal-message"></p>
                </div>
            </div>
            
            <form method="POST">
                <input type="hidden" name="csrf_token" value="<?php echo generateCSRFToken(); ?>">
                <input type="hidden" name="action" value="respond_ticket">
                <input type="hidden" name="ticket_id" id="modal-ticket-id">
                
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-300 mb-2">Response *</label>
                        <textarea name="response" rows="6" 
                                  class="w-full px-4 py-3 bg-gray-800 border border-gray-600 rounded-lg text-white focus:border-emerald-500 focus:outline-none"
                                  placeholder="Enter your response to the customer..." required></textarea>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-300 mb-2">Update Status</label>
                        <select name="status" class="w-full px-4 py-3 bg-gray-800 border border-gray-600 rounded-lg text-white focus:border-emerald-500 focus:outline-none">
                            <option value="in_progress">In Progress</option>
                            <option value="resolved">Resolved</option>
                            <option value="closed">Closed</option>
                        </select>
                    </div>
                </div>
                
                <div class="flex space-x-3 mt-6">
                    <button type="submit" class="flex-1 px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg font-medium transition">
                        <i class="fas fa-paper-plane mr-2"></i>Send Response
                    </button>
                    <button type="button" onclick="closeModal()" class="px-4 py-2 bg-gray-600 hover:bg-gray-700 text-white rounded-lg font-medium transition">
                        Cancel
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Quick Status Update Modal -->
    <div id="statusModal" class="modal fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
        <div class="glass-card rounded-xl p-6 max-w-md w-full">
            <div class="flex items-center justify-between mb-6">
                <h3 class="text-xl font-bold text-white">Update Ticket</h3>
                <button onclick="closeStatusModal()" class="text-gray-400 hover:text-white">
                    <i class="fas fa-times text-xl"></i>
                </button>
            </div>
            
            <div class="space-y-4">
                <!-- Status Update Form -->
                <form method="POST" class="space-y-4">
                    <input type="hidden" name="csrf_token" value="<?php echo generateCSRFToken(); ?>">
                    <input type="hidden" name="action" value="update_status">
                    <input type="hidden" name="ticket_id" id="status-ticket-id">
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-300 mb-2">Status</label>
                        <select name="status" id="status-select" class="w-full px-4 py-3 bg-gray-800 border border-gray-600 rounded-lg text-white focus:border-emerald-500 focus:outline-none">
                            <option value="open">Open</option>
                            <option value="in_progress">In Progress</option>
                            <option value="resolved">Resolved</option>
                            <option value="closed">Closed</option>
                        </select>
                    </div>
                    
                    <button type="submit" class="w-full px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition">
                        Update Status
                    </button>
                </form>

                <!-- Priority Update Form -->
                <form method="POST" class="space-y-4 border-t border-gray-700 pt-4">
                    <input type="hidden" name="csrf_token" value="<?php echo generateCSRFToken(); ?>">
                    <input type="hidden" name="action" value="update_priority">
                    <input type="hidden" name="ticket_id" id="priority-ticket-id">
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-300 mb-2">Priority</label>
                        <select name="priority" id="priority-select" class="w-full px-4 py-3 bg-gray-800 border border-gray-600 rounded-lg text-white focus:border-emerald-500 focus:outline-none">
                            <option value="low">Low</option>
                            <option value="medium">Medium</option>
                            <option value="high">High</option>
                            <option value="urgent">Urgent</option>
                        </select>
                    </div>
                    
                    <button type="submit" class="w-full px-4 py-2 bg-orange-600 hover:bg-orange-700 text-white rounded-lg font-medium transition">
                        Update Priority
                    </button>
                </form>
            </div>
        </div>
    </div>

    <script>
        function openTicketModal(ticket) {
            document.getElementById('modal-subject').textContent = ticket.subject;
            document.getElementById('modal-user').textContent = ticket.full_name;
            document.getElementById('modal-email').textContent = ticket.email;
            document.getElementById('modal-created').textContent = new Date(ticket.created_at).toLocaleDateString();
            document.getElementById('modal-id').textContent = ticket.id;
            document.getElementById('modal-message').textContent = ticket.message;
            document.getElementById('modal-ticket-id').value = ticket.id;
            
            document.getElementById('responseModal').classList.add('show');
        }

        function quickStatusUpdate(ticketId, currentStatus) {
            document.getElementById('status-ticket-id').value = ticketId;
            document.getElementById('priority-ticket-id').value = ticketId;
            document.getElementById('status-select').value = currentStatus;
            
            document.getElementById('statusModal').classList.add('show');
        }

        function closeModal() {
            document.getElementById('responseModal').classList.remove('show');
        }

        function closeStatusModal() {
            document.getElementById('statusModal').classList.remove('show');
        }

        // Close modals when clicking outside
        document.getElementById('responseModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeModal();
            }
        });

        document.getElementById('statusModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeStatusModal();
            }
        });

        // Auto-refresh every 30 seconds for new tickets
        setInterval(function() {
            // Only refresh if no modals are open
            if (!document.querySelector('.modal.show')) {
                location.reload();
            }
        }, 30000);

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeModal();
                closeStatusModal();
            }
        });
    </script>
</body>
</html>
