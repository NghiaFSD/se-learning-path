const chatWindow = document.getElementById('chatWindow');
const chatForm = document.getElementById('chatForm');
const chatInput = document.getElementById('chatInput');

const endpoint = '../ai-chat';

const simulateAiReply = (question) => {
    const lower = question.toLowerCase();
    if (lower.includes('glucose') || lower.includes('blood sugar')) {
        return 'Please share your latest glucose level and whether you have eaten recently.';
    }
    if (lower.includes('bmi') || lower.includes('weight') || lower.includes('height')) {
        return 'I can help with BMI. Please tell me your height and weight.';
    }
    if (lower.includes('symptom') || lower.includes('pain') || lower.includes('fatigue')) {
        return 'Please describe your current symptoms and any recent changes in your energy levels.';
    }
    if (lower.includes('family') || lower.includes('history')) {
        return 'Tell me if there is any family history of diabetes or related conditions.';
    }
    return 'Thank you. Please share additional health information like blood pressure, lifestyle habits, or symptoms.';
};

const addMessage = (text, type = 'incoming') => {
    const message = document.createElement('div');
    message.className = `message ${type}`; // Sửa từ chat-message thành message
    
    const avatar = document.createElement('div');
    avatar.className = `message-avatar ${type === 'incoming' ? 'ai' : 'user'}`;
    avatar.innerHTML = type === 'incoming' ? '<i class="bi bi-robot"></i>' : 'U';
    
    const content = document.createElement('div');
    content.className = 'message-content';
    
    const bubble = document.createElement('div');
    bubble.className = 'message-bubble';
    // Hỗ trợ Markdown cơ bản (chuyển **text** thành <strong>text</strong>)
    bubble.innerHTML = text.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
    
    const time = document.createElement('div');
    time.className = 'message-time';
    time.textContent = 'Vừa xong';
    
    content.appendChild(bubble);
    content.appendChild(time);
    
    message.appendChild(avatar);
    message.appendChild(content);
    
    chatWindow.appendChild(message);
    chatWindow.scrollTop = chatWindow.scrollHeight;
};

const updateHealthSummary = (data) => {
    if (!data) return;
    
    if (data.hba1c !== undefined && data.hba1c !== 0) {
        document.getElementById('summaryHba1c').textContent = data.hba1c;
    }
    if (data.bmi !== undefined && data.bmi !== 0) {
        document.getElementById('summaryBMI').textContent = data.bmi;
    }
    if (data.tg !== undefined && data.tg !== 0) {
        document.getElementById('summaryTG').textContent = data.tg;
    }
    if (data.hdl !== undefined && data.hdl !== 0) {
        document.getElementById('summaryHDL').textContent = data.hdl;
    }
    if (data.symptoms !== undefined && data.symptoms !== "" && data.symptoms !== "0") {
        const symptomsElement = document.getElementById('summarySymptoms');
        if (symptomsElement) {
            symptomsElement.textContent = data.symptoms;
            symptomsElement.title = data.symptoms;
        }
    }
};

chatForm.addEventListener('submit', async (event) => {
    event.preventDefault();
    const text = chatInput.value.trim();
    if (!text) return;
    
    addMessage(text, 'outgoing');
    chatInput.value = '';

        // Hiển thị trạng thái đang nhập
        const typingIndicator = document.createElement('div');
        typingIndicator.className = 'message incoming';
        typingIndicator.id = 'typingIndicator';
        typingIndicator.innerHTML = `
            <div class="message-avatar ai"><i class="bi bi-robot"></i></div>
            <div class="message-content">
                <div class="typing-indicator">
                    <div class="typing-dots">
                        <span></span><span></span><span></span>
                    </div>
                </div>
            </div>
        `;
        chatWindow.appendChild(typingIndicator);
        chatWindow.scrollTop = chatWindow.scrollHeight;

        try {
            const response = await fetch(endpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `message=${encodeURIComponent(text)}`,
            });
            
            const responseText = await response.text();
            console.log("Raw Response from Servlet:", responseText);
            
            let data;
            try {
                // Thử parse JSON thô
                data = JSON.parse(responseText.trim());
            } catch (e) {
                console.error("Initial JSON Parse Error:", e);
                // Nếu thất bại, thử bóc tách JSON bằng regex (đề phòng Servlet trả về text thừa)
                const jsonMatch = responseText.match(/\{[\s\S]*\}/);
                if (jsonMatch) {
                    try {
                        data = JSON.parse(jsonMatch[0]);
                    } catch (e2) {
                        console.error("Regex JSON Parse Error:", e2);
                    }
                }
            }
            
            // Xóa indicator
            if(document.getElementById('typingIndicator')) document.getElementById('typingIndicator').remove();
            
            if (data) {
                // Xử lý trường hợp data.reply cũng là một chuỗi JSON (AI double encode)
                let finalReply = data.reply;
                let healthData = data.healthData;

                if (typeof finalReply === 'string' && finalReply.trim().startsWith('{')) {
                    try {
                        const nestedData = JSON.parse(finalReply);
                        if (nestedData.reply) {
                            finalReply = nestedData.reply;
                            if (nestedData.healthData) healthData = nestedData.healthData;
                        }
                    } catch (e) {}
                }

                if (finalReply) {
                    addMessage(finalReply, 'incoming');
                    if (healthData) updateHealthSummary(healthData);
                } else {
                    addMessage("Xin lỗi, AI trả về dữ liệu không đúng cấu trúc.", 'incoming');
                }
            } else {
                addMessage("Lỗi cấu trúc dữ liệu từ máy chủ. Vui lòng thử lại.", 'incoming');
            }
        } catch (error) {
            console.error("Chat error:", error);
            if(document.getElementById('typingIndicator')) document.getElementById('typingIndicator').remove();
            addMessage("Không thể kết nối với máy chủ. Vui lòng kiểm tra mạng.", 'incoming');
        }
});
