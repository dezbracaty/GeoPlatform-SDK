#pragma once

#include "ParametricModelTypes.hpp"
#include <functional>

namespace GPlatform::Parametric {

class TransactionAdapter {
public:
    using CommandExecutor = std::function<CommandResult()>;

    CommandResult executeTopLevelCommand(const QString& description,
                                         const CommandExecutor& executor) const;
};

} // namespace GPlatform::Parametric
