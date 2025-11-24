# Demo Workflow

End-to-end demo workflow for stakeholders, partners, and grantees.

## Pre-Demo Setup

1. **Deploy Backend** to Render/Heroku
2. **Deploy Frontend** to Render/Vercel
3. **Ensure Dojo World** is deployed on Sepolia
4. **Test all flows** locally first

## Demo Script

### 1. Introduction (2 min)

- **What**: Simple Clicker Game - On-chain clicker game demo
- **Why**: Showcase gasless transactions, session keys, and on-chain gaming
- **Tech**: Dojo, Starknet, React/Unity

### 2. Setup & Wallet Creation (3 min)

**Live Demo:**
1. Open web app: `https://your-app.onrender.com`
2. Enter player address (Starknet)
3. Click "Create Wallet (Session Key)"
4. Show: Session key created, stored locally
5. Explain: Gasless transactions enabled

**Key Points:**
- No wallet popups needed
- Session keys enable seamless UX
- Self-custody maintained

### 3. Clicker Game (5 min)

**Live Demo:**
1. Click "🖱️ Click!" button multiple times
2. Show: Points increasing, stats updating
3. Click "Buy Upgrade"
4. Show: Click power increased
5. Click more - show faster point accumulation
6. Refresh state - show real-time updates

**Key Points:**
- On-chain game state
- Real-time updates via Torii
- Gasless game actions

### 4. Unity Integration (3 min)

**Show:**
1. Open Unity project
2. Show same flows in Unity
3. Demonstrate cross-platform compatibility
4. Show code structure (API calls mirror web)

**Key Points:**
- Same API, different client
- Easy to port to mobile
- Consistent experience

### 5. Technical Deep Dive (Optional, 5 min)

**Show:**
- Backend API code structure
- Dojo contract integration
- Torii GraphQL queries
- Session key management

**Key Points:**
- Modular architecture
- Easy to extend
- Well-documented

## Demo Checklist

- [ ] Backend deployed and accessible
- [ ] Frontend deployed and accessible
- [ ] Dojo world deployed on Sepolia
- [ ] Test account funded with Sepolia ETH
- [ ] All endpoints tested and working
- [ ] Demo data prepared (addresses, etc.)
- [ ] Unity project ready (if showing)
- [ ] Backup plan (recorded demo if live fails)

## Common Questions

**Q: Is this production-ready?**
A: This is a demo/prototype. Production would need additional security, error handling, and testing.

**Q: How does gasless work?**
A: Cartridge Controller sponsors gas fees via paymaster. Users sign with session keys.

**Q: Can this scale?**
A: Yes, backend can scale horizontally. Dojo/Starknet handle on-chain scaling.

**Q: What about security?**
A: Session keys are temporary and scoped. Main wallet remains secure.

**Q: How do I integrate this?**
A: See `QUICKSTART.md` and `UNITY_INTEGRATION.md` for step-by-step guides.

## Post-Demo

1. **Share Resources:**
   - GitHub repo
   - Documentation links
   - Contact info

2. **Collect Feedback:**
   - What worked well?
   - What needs improvement?
   - Feature requests?

3. **Follow-up:**
   - Schedule technical deep dive if needed
   - Provide access to code/docs
   - Answer questions

## Tips

- **Keep it simple**: Focus on core flows, not edge cases
- **Be prepared**: Have backup demo ready
- **Show, don't tell**: Live demo > slides
- **Engage audience**: Ask questions, get feedback
- **Time management**: Stick to script, leave time for Q&A

## Resources

- API Docs: `docs/API.md`
- Quick Start: `docs/QUICKSTART.md`
- Unity Guide: `docs/UNITY_INTEGRATION.md`
- GitHub: [Your repo URL]

