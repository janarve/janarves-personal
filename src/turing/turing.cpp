#include "turing.h"

bool QTuringStateMachine::step()
{
    if (m_position >= m_memory.size())
        m_memory.resize(m_position + 1);
    unsigned char condition = m_state + (m_memory.at(m_position) ? 0x80 : 0);
    Operation oper = m_instructionSet.at(condition);
    if (!oper.isValid())
        return false;
    m_state = oper.state();
    if (m_position >= m_memory.size())
        m_memory.resize(m_position + 1);

    m_memory.setBit(m_position, oper.bit());
    m_position += oper.direction();
    return true;
}

void QTuringStateMachine::evaluate(int position /*= 0*/, int state /*= 1*/)
{
    m_state = state;
    m_position = position;
    while (step()) {}
}


void QTuringStateMachine::setMemory(const char *sequence) {
    m_memory.fill(false);
    const int len = qstrlen(sequence);
    if (len > m_memory.size())
        m_memory.resize(len);
    for (int i = 0; sequence[i]; ++i) {
        m_memory.setBit(i, sequence[i] == '1' ? true : false);
    }
}

QByteArray QTuringStateMachine::memory() const
{
    QByteArray mem;
    for (int i = 0; i < m_memory.size(); ++i) {
        mem.append(m_memory.at(i) ? "1" : "0");
    }
    return mem;
}

void QTuringStateMachine::reset()
{
    m_instructionSet.fill(Operation());
    m_state = 1;
    m_position = 0;
    m_memory.fill(false);
}

QDebug operator<<(QDebug debug, const QTuringStateMachine &stateMachine)
{
    debug << QString::fromAscii("state: %1, position: %2, mem: %3")
                                .arg(int(stateMachine.state()))
                                .arg(stateMachine.position())
                                .arg(stateMachine.memory().constData());
    return debug;
}

