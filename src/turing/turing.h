#include <QtCore/qglobal.h>
#include <QtCore/QVector>
#include <QtCore/QBitArray>
#include <qdebug>
class QTuringStateMachine {
    public:
    class Operation {
    public:
        Operation(const Operation &other) : o(other.o) {}
        Operation(unsigned short oper) : o(oper) {}
        Operation() : o(0xffff) {}
        inline bool bit() const { return o & 0x80 ? true : false; }
        inline unsigned char state() const { return o & 0x7f; }
        inline int direction() const { return o & 0x100 ? +1 : -1; }
        inline operator unsigned char() { return o;}
        inline bool isValid() const { return o == 0xffff ? false : true; }
    private:
        unsigned short o;   //[0..6] state
                            //[7] bit
                            //[8] direction,  1: +1,  0: -1
                            //[9..15] available
    };

    class Condition {
    public:
        Condition(unsigned char cond) : c(cond) {}
        inline bool bit() const { return c & 0x80 ? true : false; }
        inline unsigned char state() const { return c & 0x7f; }
        inline operator unsigned char() { return c;}
    private:
        Condition() {}
        unsigned char c;    //[0..6] state
                            //[7]    bit
    };

    class Instruction {
    public:
        Instruction(const char *mnemonic)
            : m_condition(mnemonic[0] - 0x30 + (mnemonic[1] == 'x' ? 0x80 : 0)),
              m_operation(mnemonic[3] - 0x30 + (mnemonic[2] == 'x' ? 0x80 : 0) + (mnemonic[4] == 'r' ? 0x100 : 0))
        {
        }
        Instruction(char fromstate, bool frombit, char tostate, bool tobit, bool direction)
            : m_condition(fromstate + (frombit ? 0x80 : 0)),
              m_operation(tostate + (tobit ? 0x80 : 0) + direction ? 0x100 : 0x00)
        {
        }

        inline Condition condition() const {
            return m_condition;
        }

        inline Operation operation() const {
            return m_operation;
        }

        bool operator==(const Instruction &other)
        {
            return other.condition() == condition();
        }

        Condition m_condition;
        Operation m_operation;
        Instruction() : m_condition(0), m_operation(0xffff)
        {}
    };
    QTuringStateMachine(int alloc = 1)
    {
        m_memory.resize(alloc);
        m_instructionSet.resize(256);
        m_state = 1;
    }

    QTuringStateMachine &operator<<(const Instruction &instruction)
    {
        addInstruction(instruction);
        return (*this);
    }

    bool step();

    void evaluate(int position = 0, int state = 1);

    void setMemory(const char *sequence);

    QByteArray memory() const;

    void reset();

    char state() const
    {
        return m_state;
    }

    int position() const
    {
        return m_position;
    }

private:
    void addInstruction(const Instruction &instruction)
    {
        m_instructionSet.replace(instruction.condition(), instruction.operation());
    }

    QVector<Operation> m_instructionSet;
    QBitArray m_memory;
    char m_state;
    int m_position;

};

QDebug operator<<(QDebug debug, const QTuringStateMachine &stateMachine);


