#include <QtGui>
#include "turing.h"
#include <QtCore/QRegExp>

int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);
    QStringList args = app.arguments();
    if (args.count() > 1) {
        QTuringStateMachine machine;
        QFile file(args.at(1));
        if (file.open(QIODevice::ReadOnly)) {
            QTextStream input(&file);
            QString func;
            while (!input.atEnd()) {
                QString line = input.readLine();
                if (line.startsWith(QLatin1Char('#')))
                    continue;
                line = line.simplified();
                if (line.isEmpty())
                    continue;
                QRegExp rxFunc(QLatin1String("function ([a-zA-Z][a-zA-Z0-9]*) \\{"));
                QRegExp rxEnd(QLatin1String("\\}"));
                QRegExp rxMem(QLatin1String("memory: *([01]+)"));
                if (rxFunc.exactMatch(line)) {
                    func = rxFunc.cap(1);
                } else if (rxEnd.exactMatch(line)) {
                    qDebug() << "--------------------------------------";
                    qDebug() << "evaluating.......:" << func;
                    qDebug() << "initial machine..:" << machine;
                    machine.evaluate();
                    qDebug() << "resulting machine:" << machine;
                    machine.reset();
                } else if (rxMem.exactMatch(line)) {
                    QByteArray mem = rxMem.cap(1).toLatin1();
                    machine.setMemory(mem.constData());
                } else {
                    QByteArray instr = line.toLatin1();
                    machine << QTuringStateMachine::Instruction(instr.constData());
                }
            }
        }
    }else{
        QTuringStateMachine machine;

        // AddOne
        machine.setMemory("11");
        machine << QTuringStateMachine::Instruction("1xx1r");
        machine << QTuringStateMachine::Instruction("1bx2r");
        machine.evaluate();
        qDebug() << machine;


        // AddTwo
        machine.reset();
        machine.setMemory("11");
        machine << QTuringStateMachine::Instruction("1xx1r");
        machine << QTuringStateMachine::Instruction("1bx2r");
        machine << QTuringStateMachine::Instruction("2bx3r");
        machine.evaluate();
        qDebug() << machine;

        //Double
        machine.reset();
        machine.setMemory("1111");
        machine << QTuringStateMachine::Instruction("1xb2r");       //bbbxxbbbbbbbb
        machine << QTuringStateMachine::Instruction("2xx2r");
        machine << QTuringStateMachine::Instruction("2bb3r");
        machine << QTuringStateMachine::Instruction("3xx3r");
        machine << QTuringStateMachine::Instruction("3bx4r");
        machine << QTuringStateMachine::Instruction("4bx5l");
        machine << QTuringStateMachine::Instruction("5xx5l");
        machine << QTuringStateMachine::Instruction("5bb6l");
        machine << QTuringStateMachine::Instruction("6xx6l");
        machine << QTuringStateMachine::Instruction("6bb1r");
        machine.evaluate();
        qDebug() << machine;
    }

    return app.exit();
}
